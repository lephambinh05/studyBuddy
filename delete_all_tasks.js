const admin = require('firebase-admin');

// Khởi tạo Firebase Admin SDK
if (!admin.apps.length) {
  try {
    // Thử sử dụng service account key
    const serviceAccount = require('./serviceAccountKey.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('✅ Đã khởi tạo Firebase với service account key');
  } catch (error) {
    // Sử dụng Application Default Credentials
    admin.initializeApp();
    console.log('✅ Đã khởi tạo Firebase với Application Default Credentials');
  }
}

const db = admin.firestore();

async function deleteAllTasks() {
  try {
    console.log('🚀 Bắt đầu xóa toàn bộ tasks...');
    console.log('='.repeat(50));
    
    // Lấy collection 'tasks'
    const tasksRef = db.collection('tasks');
    
    // Lấy tất cả documents
    const snapshot = await tasksRef.get();
    
    if (snapshot.empty) {
      console.log('✅ Không có tasks nào để xóa!');
      return;
    }
    
    console.log(`🔍 Tìm thấy ${snapshot.size} tasks để xóa...`);
    
    let deletedCount = 0;
    
    // Xóa từng document
    for (const doc of snapshot.docs) {
      console.log(`🗑️ Đang xóa task: ${doc.id}`);
      console.log(`   Data:`, doc.data());
      
      await doc.ref.delete();
      deletedCount++;
    }
    
    console.log(`✅ Đã xóa thành công ${deletedCount} tasks!`);
    
    // Kiểm tra lại
    const remainingSnapshot = await tasksRef.get();
    
    if (remainingSnapshot.empty) {
      console.log('✅ Collection "tasks" đã trống!');
    } else {
      console.log(`⚠️ Vẫn còn ${remainingSnapshot.size} tasks (có thể do lỗi)`);
    }
    
  } catch (error) {
    console.error('❌ Lỗi:', error);
  }
}

// Chạy script
deleteAllTasks().then(() => {
  console.log('='.repeat(50));
  console.log('✅ Hoàn thành!');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Thất bại:', error);
  process.exit(1);
}); 