import React, { useState, useEffect } from 'react';
import axios from 'axios'; // Nhớ cài: npm install axios

const AssignmentPage = () => {
  const [paperId, setPaperId] = useState('');
  const [paperTitle, setPaperTitle] = useState('');
  const [reviewers, setReviewers] = useState([]);
  const [selectedReviewer, setSelectedReviewer] = useState('');
  const [aiReasoning, setAiReasoning] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  // 1. Hàm gọi AI Gợi ý (Tính năng ăn tiền của bạn)
  const handleGetAiSuggestion = async () => {
    if (!paperId) return alert("Vui lòng nhập ID bài báo!");
    setLoading(true);
    setAiReasoning('');
    setMessage('');
    
    try {
      // Gọi API Auto-Assign của Backend
      const res = await axios.post('http://127.0.0.1:5000/api/auto-assign', {
        paper_id: paperId
      });
      
      setPaperTitle(res.data.paper_title);
      setAiReasoning(res.data.ai_suggestion); // Hiển thị lời khuyên của AI
      
      // Sau khi AI gợi ý, tải luôn danh sách Reviewer để Admin chọn
      fetchAvailableReviewers();
      
    } catch (err) {
      console.error(err);
      setMessage('Lỗi: ' + (err.response?.data?.error || "Không gọi được AI"));
    } finally {
      setLoading(false);
    }
  };

  // 2. Hàm lấy danh sách Reviewer (Đã lọc COI)
  const fetchAvailableReviewers = async () => {
    try {
      const res = await axios.get(`http://127.0.0.1:5000/api/reviewers-available/${paperId}`);
      setReviewers(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  // 3. Hàm Lưu phân công (Admin chốt đơn)
  const handleAssign = async () => {
    if (!selectedReviewer) return alert("Chưa chọn Reviewer!");
    
    try {
      const res = await axios.post('http://127.0.0.1:5000/api/assign', {
        paper_id: paperId,
        reviewer_id: selectedReviewer
      });
      setMessage("✅ " + res.data.message);
    } catch (err) {
      setMessage("❌ " + (err.response?.data?.error || "Lỗi server"));
    }
  };

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>🎓 Phân Công Phản Biện (AI Support)</h1>
      
      {/* KHUNG NHẬP ID BÀI BÁO */}
      <div style={{ marginBottom: '20px' }}>
        <label>Nhập ID Bài báo cần chấm: </label>
        <input 
          type="number" 
          value={paperId} 
          onChange={(e) => setPaperId(e.target.value)}
          placeholder="VD: 1"
          style={{ padding: '8px', marginRight: '10px' }}
        />
        <button onClick={handleGetAiSuggestion} disabled={loading} style={{ padding: '8px 15px', cursor: 'pointer' }}>
          {loading ? "AI đang đọc bài..." : "🤖 Hỏi ý kiến AI"}
        </button>
      </div>

      {/* KHUNG KẾT QUẢ AI */}
      {paperTitle && (
        <div style={{ border: '1px solid #ddd', padding: '15px', borderRadius: '5px', backgroundColor: '#f9f9f9' }}>
          <h3>📄 Bài báo: {paperTitle}</h3>
          
          <div style={{ backgroundColor: '#e3f2fd', padding: '10px', borderRadius: '5px', marginBottom: '15px' }}>
            <strong>💡 AI Gemini đề xuất:</strong>
            <p style={{ whiteSpace: 'pre-line' }}>{aiReasoning}</p>
          </div>

          {/* DROPDOWN CHỌN NGƯỜI */}
          <div>
            <label><strong>Chọn Reviewer: </strong></label>
            <select 
              value={selectedReviewer} 
              onChange={(e) => setSelectedReviewer(e.target.value)}
              style={{ padding: '8px', marginLeft: '10px', width: '200px' }}
            >
              <option value="">-- Chọn Giám Khảo --</option>
              {reviewers.map((r) => (
                <option key={r.id} value={r.id}>
                  ID {r.id} - {r.name} ({r.email})
                </option>
              ))}
            </select>
            
            <button 
              onClick={handleAssign}
              style={{ marginLeft: '10px', padding: '8px 20px', backgroundColor: '#4CAF50', color: 'white', border: 'none', cursor: 'pointer' }}
            >
              💾 Xác nhận Phân công
            </button>
          </div>
          
          {message && <p style={{ marginTop: '10px', fontWeight: 'bold' }}>{message}</p>}
        </div>
      )}
    </div>
  );
};

export default AssignmentPage;