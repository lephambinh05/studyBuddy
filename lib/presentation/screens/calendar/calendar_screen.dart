import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studybuddy/core/theme/app_theme.dart';
import 'package:studybuddy/presentation/widgets/common/gradient_card.dart';
import 'package:studybuddy/presentation/widgets/event/event_form_dialog.dart';
import 'package:studybuddy/data/models/event_model.dart';
import 'package:studybuddy/presentation/providers/event_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  
  final List<String> _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventProvider.notifier).loadEvents();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(theme),
            ),
            
            // Calendar
            SliverToBoxAdapter(
              child: _buildCalendar(theme),
            ),
            
            // Events for selected date
            SliverToBoxAdapter(
              child: _buildEventsList(theme),
            ),
            
            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_fab',
        onPressed: () {
          _showAddEventDialog(context);
        },
        backgroundColor: AppThemes.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppThemes.primaryGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Calendar',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.today, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _focusedDate = DateTime.now();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  title: 'Today\'s event',
                  value: '3',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  title: 'This week',
                  value: '12',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  title: 'This month',
                  value: '45',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month/Year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Week days header
          Row(
            children: _weekDays.map((day) {
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Calendar grid
          _buildCalendarGrid(theme),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    final weeks = <List<Widget>>[];
    List<Widget> currentWeek = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      currentWeek.add(_buildEmptyDay());
    }
    
    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      currentWeek.add(_buildDayCell(date, theme));
      
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    
    // Add remaining empty cells
    while (currentWeek.length < 7) {
      currentWeek.add(_buildEmptyDay());
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }
    
    return Column(
      children: weeks.map((week) {
        return Row(
          children: week,
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(DateTime date, ThemeData theme) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasEvents = _hasEventsOnDate(date);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = date;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(2),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected 
                ? AppThemes.primaryColor 
                : isToday 
                    ? AppThemes.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday 
                ? Border.all(color: AppThemes.primaryColor, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  date.day.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected 
                        ? Colors.white 
                        : isToday 
                            ? AppThemes.primaryColor
                            : null,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (hasEvents)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppThemes.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDay() {
    return const Expanded(
      child: SizedBox(height: 40),
    );
  }

  Widget _buildEventsList(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEventsForSelectedDate(theme),
        ],
      ),
    );
  }

  Widget _buildEventsForSelectedDate(ThemeData theme) {
    // Get events from provider
    final eventState = ref.watch(eventProvider);
    final events = eventState.events.where((event) {
      final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      return eventDate.isAtSameMomentAs(selectedDate);
    }).toList();
    
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No event',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new event for today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddEventDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: events.map((event) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEventCard(event, theme),
        );
      }).toList(),
    );
  }

  Widget _buildEventCard(EventModel event, ThemeData theme) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: _getEventColor(event.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getEventColor(event.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getEventColor(event.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.iconTheme.color,
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditEventDialog(context, event);
                  break;
                case 'delete':
                  _showDeleteEventConfirmation(context, event);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Event'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Event', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _hasEventsOnDate(DateTime date) {
    // Check if date has events from provider
    final eventState = ref.read(eventProvider);
    return eventState.events.any((event) {
      final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final checkDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(checkDate);
    });
  }



  Color _getEventColor(String type) {
    switch (type) {
        case 'Study':
        return AppThemes.primaryColor;
      case 'Exercise':
        return AppThemes.accentColor;
      case 'Entertainment':
        return AppThemes.secondaryColor;
      default:
        return AppThemes.warningColor;
    }
  }

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        onSave: (newEvent) async {
          try {
            await ref.read(eventProvider.notifier).addEvent(newEvent);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event "${newEvent.title}" has been added'),
                  backgroundColor: AppThemes.primaryColor,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot add event. Please try again later.'),
                  backgroundColor: AppThemes.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, EventModel event) {
    
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        event: event,
        onSave: (updatedEvent) async {
          try {
            await ref.read(eventProvider.notifier).updateEvent(event.id, updatedEvent);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event "${updatedEvent.title}" has been updated'),
                  backgroundColor: AppThemes.primaryColor,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot update event. Please try again later.'),
                  backgroundColor: AppThemes.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteEventConfirmation(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text('Are you sure you want to delete the event "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(eventProvider.notifier).deleteEvent(event.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event "${event.title}" has been deleted'),
                      backgroundColor: AppThemes.primaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cannot delete event. Please try again later.'),
                      backgroundColor: AppThemes.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
} 