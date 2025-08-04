#!/usr/bin/env node

/**
 * StudyBuddy Data Import Script (Node.js version)
 * Sử dụng: node scripts/import_data.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

class StudyBuddyDataImporter {
    constructor(serviceAccountPath = null) {
        if (serviceAccountPath && fs.existsSync(serviceAccountPath)) {
            // Sử dụng service account file
            const serviceAccount = require(path.resolve(serviceAccountPath));
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount)
            });
        } else {
            // Sử dụng default credentials
            admin.initializeApp();
        }
        
        this.db = admin.firestore();
        console.log('✅ Đã kết nối Firebase thành công!');
    }

    async importTasks(tasksData) {
        console.log(`📝 Đang import ${tasksData.length} tasks...`);
        
        const batch = this.db.batch();
        const tasksRef = this.db.collection('tasks');
        
        for (const taskData of tasksData) {
            const docRef = tasksRef.doc();
            
            const firestoreData = {
                id: docRef.id,
                title: taskData.title,
                description: taskData.description || null,
                subject: taskData.subject,
                deadline: taskData.deadline,
                isCompleted: taskData.isCompleted,
                priority: taskData.priority,
                createdAt: taskData.createdAt,
                completedAt: taskData.completedAt || null
            };
            
            batch.set(docRef, firestoreData);
        }
        
        await batch.commit();
        console.log(`✅ Đã import ${tasksData.length} tasks thành công!`);
    }

    async importEvents(eventsData) {
        console.log(`📅 Đang import ${eventsData.length} events...`);
        
        const batch = this.db.batch();
        const eventsRef = this.db.collection('events');
        
        for (const eventData of eventsData) {
            const docRef = eventsRef.doc();
            
            const firestoreData = {
                id: docRef.id,
                title: eventData.title,
                description: eventData.description || null,
                startTime: eventData.startTime,
                endTime: eventData.endTime,
                type: eventData.type,
                subject: eventData.subject || null,
                location: eventData.location || null,
                isAllDay: eventData.isAllDay,
                color: eventData.color
            };
            
            batch.set(docRef, firestoreData);
        }
        
        await batch.commit();
        console.log(`✅ Đã import ${eventsData.length} events thành công!`);
    }

    async importUsers(usersData) {
        console.log(`👤 Đang import ${usersData.length} users...`);
        
        const batch = this.db.batch();
        const usersRef = this.db.collection('users');
        
        for (const userData of usersData) {
            const docRef = usersRef.doc();
            
            const firestoreData = {
                id: docRef.id,
                name: userData.name,
                email: userData.email,
                avatar: userData.avatar || null,
                grade: userData.grade || null,
                school: userData.school || null,
                createdAt: userData.createdAt,
                lastLoginAt: userData.lastLoginAt || null
            };
            
            batch.set(docRef, firestoreData);
        }
        
        await batch.commit();
        console.log(`✅ Đã import ${usersData.length} users thành công!`);
    }

    async clearCollection(collectionName) {
        console.log(`🗑️ Đang xóa collection '${collectionName}'...`);
        
        const snapshot = await this.db.collection(collectionName).get();
        const batch = this.db.batch();
        
        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });
        
        await batch.commit();
        console.log(`✅ Đã xóa collection '${collectionName}' thành công!`);
    }

    getSampleData() {
        const now = new Date();
        
        // Sample Tasks
        const tasks = [
            {
                title: 'Làm bài tập Toán chương 3',
                description: 'Hoàn thành các bài tập từ trang 45-50 trong sách giáo khoa',
                subject: 'Toán',
                deadline: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000).toISOString(),
                isCompleted: false,
                priority: 2,
                createdAt: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000).toISOString(),
                completedAt: null
            },
            {
                title: 'Ôn tập từ vựng tiếng Anh',
                description: 'Học 50 từ mới trong Unit 5 và làm bài tập vocabulary',
                subject: 'Anh',
                deadline: new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000).toISOString(),
                isCompleted: true,
                priority: 1,
                createdAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000).toISOString(),
                completedAt: new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString()
            },
            {
                title: 'Đọc sách Văn học',
                description: 'Đọc và phân tích tác phẩm "Truyện Kiều" của Nguyễn Du',
                subject: 'Văn',
                deadline: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000).toISOString(),
                isCompleted: false,
                priority: 3,
                createdAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000).toISOString(),
                completedAt: null
            },
            {
                title: 'Làm thí nghiệm Hóa học',
                description: 'Thực hành thí nghiệm về phản ứng oxi hóa khử trong phòng lab',
                subject: 'Hóa',
                deadline: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000).toISOString(),
                isCompleted: false,
                priority: 1,
                createdAt: new Date(now.getTime() - 4 * 24 * 60 * 60 * 1000).toISOString(),
                completedAt: null
            },
            {
                title: 'Học lý thuyết Vật lý',
                description: 'Ôn tập chương điện học và từ học, chuẩn bị cho bài kiểm tra',
                subject: 'Lý',
                deadline: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000).toISOString(),
                isCompleted: false,
                priority: 2,
                createdAt: new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000).toISOString(),
                completedAt: null
            }
        ];

        // Sample Events
        const events = [
            {
                title: 'Học Toán',
                description: 'Ôn tập chương 3 về đạo hàm và ứng dụng',
                startTime: new Date(now.getTime() + 2 * 60 * 60 * 1000).toISOString(),
                endTime: new Date(now.getTime() + 4 * 60 * 60 * 1000).toISOString(),
                type: 'study',
                subject: 'Toán',
                location: 'Thư viện trường',
                isAllDay: false,
                color: '#FF6B6B'
            },
            {
                title: 'Kiểm tra Văn',
                description: 'Kiểm tra 15 phút về tác phẩm văn học',
                startTime: new Date(now.getTime() + 24 * 60 * 60 * 1000 + 8 * 60 * 60 * 1000).toISOString(),
                endTime: new Date(now.getTime() + 24 * 60 * 60 * 1000 + 8 * 60 * 60 * 1000 + 15 * 60 * 1000).toISOString(),
                type: 'exam',
                subject: 'Văn',
                location: 'Lớp 12A1',
                isAllDay: false,
                color: '#4ECDC4'
            },
            {
                title: 'Nhóm học tập',
                description: 'Thảo luận nhóm về bài tập Hóa học',
                startTime: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000 + 14 * 60 * 60 * 1000).toISOString(),
                endTime: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000 + 16 * 60 * 60 * 1000).toISOString(),
                type: 'study',
                subject: 'Hóa',
                location: 'Phòng học nhóm',
                isAllDay: false,
                color: '#45B7D1'
            }
        ];

        // Sample Users
        const users = [
            {
                name: 'Nguyễn Văn An',
                email: 'an.nguyen@example.com',
                avatar: 'https://example.com/avatar1.jpg',
                grade: '12',
                school: 'THPT Chuyên Hà Nội - Amsterdam',
                createdAt: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString(),
                lastLoginAt: now.toISOString()
            },
            {
                name: 'Trần Thị Bình',
                email: 'binh.tran@example.com',
                avatar: 'https://example.com/avatar2.jpg',
                grade: '12',
                school: 'THPT Chuyên Hà Nội - Amsterdam',
                createdAt: new Date(now.getTime() - 25 * 24 * 60 * 60 * 1000).toISOString(),
                lastLoginAt: new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString()
            },
            {
                name: 'Lê Hoàng Cường',
                email: 'cuong.le@example.com',
                avatar: 'https://example.com/avatar3.jpg',
                grade: '12',
                school: 'THPT Chuyên Hà Nội - Amsterdam',
                createdAt: new Date(now.getTime() - 20 * 24 * 60 * 60 * 1000).toISOString(),
                lastLoginAt: new Date(now.getTime() - 5 * 60 * 60 * 1000).toISOString()
            }
        ];

        return {
            tasks,
            events,
            users
        };
    }
}

async function main() {
    console.log('🚀 Bắt đầu import data vào Firebase...');
    console.log('='.repeat(50));
    
    try {
        // Khởi tạo importer
        const serviceAccountPath = null; // "path/to/serviceAccountKey.json"
        const importer = new StudyBuddyDataImporter(serviceAccountPath);
        
        // Lấy sample data
        const sampleData = importer.getSampleData();
        
        // Hỏi user có muốn xóa data cũ không
        const readline = require('readline');
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        
        const clearOld = await new Promise((resolve) => {
            rl.question('🗑️ Có muốn xóa data cũ không? (y/N): ', (answer) => {
                resolve(answer.toLowerCase().trim() === 'y');
                rl.close();
            });
        });
        
        if (clearOld) {
            console.log('🗑️ Đang xóa data cũ...');
            await importer.clearCollection('tasks');
            await importer.clearCollection('events');
            await importer.clearCollection('users');
            console.log('✅ Đã xóa data cũ thành công!');
        }
        
        // Import data
        console.log('\n📊 Bắt đầu import data...');
        await importer.importTasks(sampleData.tasks);
        await importer.importEvents(sampleData.events);
        await importer.importUsers(sampleData.users);
        
        console.log('\n🎉 Import data thành công!');
        console.log('='.repeat(50));
        console.log('📝 Đã import:');
        console.log(`   - ${sampleData.tasks.length} tasks`);
        console.log(`   - ${sampleData.events.length} events`);
        console.log(`   - ${sampleData.users.length} users`);
        console.log('='.repeat(50));
        
    } catch (error) {
        console.error(`❌ Lỗi: ${error.message}`);
        process.exit(1);
    }
}

if (require.main === module) {
    main();
}

module.exports = StudyBuddyDataImporter; 