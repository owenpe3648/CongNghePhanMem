from flask import Blueprint, request, jsonify
from datetime import datetime

decision_bp = Blueprint('decision', __name__)

# Mock Data
mock_papers_db = [
    {"id": 101, "title": "Nghiên cứu AI trong Y tế", "author": "Nguyen Van A", "score": 8.5, "status": "REVIEWED"},
    {"id": 102, "title": "Blockchain và IoT", "author": "Tran Thi B", "score": 4.5, "status": "REVIEWED"},
    {"id": 103, "title": "An toàn thông tin 2025", "author": "Le Van C", "score": 7.0, "status": "REVIEWED"}
]

@decision_bp.route('/papers', methods=['GET'])
def get_papers_to_decide():
    results = [p for p in mock_papers_db if p['status'] == 'REVIEWED']
    return jsonify({"success": True, "count": len(results), "data": results})

@decision_bp.route('/make', methods=['POST'])
def make_decision():
    data = request.json
    paper_id = data.get('paper_id')
    new_status = data.get('decision')
    
    if new_status not in ['ACCEPTED', 'REJECTED']:
        return jsonify({"success": False, "message": "Invalid Status"}), 400

    for paper in mock_papers_db:
        if paper['id'] == paper_id:
            paper['status'] = new_status
            paper['final_decision_date'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            return jsonify({"success": True, "message": f"Updated to {new_status}", "data": paper})

    return jsonify({"success": False, "message": "Paper not found"}), 404