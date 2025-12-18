import streamlit as st
import pandas as pd

st.set_page_config(page_title="Hệ thống Duyệt Bài - TP6", layout="wide")
st.title("TP6: HỘI ĐỒNG RA QUYẾT ĐỊNH")

if 'data' not in st.session_state:
    st.session_state.data = [
        {"ID": 101, "Tên bài báo": "Nghiên cứu AI trong Y tế", "Tác giả": "Nguyen Van A", "Điểm TB": 8.5, "Trạng thái": "REVIEWED"},
        {"ID": 102, "Tên bài báo": "Blockchain và IoT", "Tác giả": "Tran Thi B", "Điểm TB": 4.5, "Trạng thái": "REVIEWED"},
        {"ID": 103, "Tên bài báo": "An toàn thông tin 2025", "Tác giả": "Le Van C", "Điểm TB": 7.0, "Trạng thái": "REVIEWED"},
        {"ID": 104, "Tên bài báo": "Phân tích dữ liệu lớn", "Tác giả": "Pham Van D", "Điểm TB": 9.0, "Trạng thái": "ACCEPTED"}
    ]

df = pd.DataFrame(st.session_state.data)
col1, col2 = st.columns([2, 1])

with col1:
    st.subheader("Danh sách bài báo")
    st.dataframe(df, use_container_width=True)

with col2:
    st.subheader("Ra Quyết Định")
    paper_ids = [p['ID'] for p in st.session_state.data if p['Trạng thái'] == 'REVIEWED']
    
    if not paper_ids:
        st.info("Không còn bài chờ duyệt.")
    else:
        selected_id = st.selectbox("Chọn ID bài báo:", paper_ids)
        comment = st.text_area("Nhận xét:")
        
        c1, c2 = st.columns(2)
        with c1:
            if st.button("DUYỆT (Accept)", type="primary", use_container_width=True):
                for p in st.session_state.data:
                    if p['ID'] == selected_id:
                        p['Trạng thái'] = 'ACCEPTED'
                st.success(f"Đã DUYỆT bài {selected_id}")
                st.rerun()
        with c2:
            if st.button("LOẠI (Reject)", use_container_width=True):
                for p in st.session_state.data:
                    if p['ID'] == selected_id:
                        p['Trạng thái'] = 'REJECTED'
                st.error(f"Đã LOẠI bài {selected_id}")
                st.rerun()