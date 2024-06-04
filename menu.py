import streamlit as st

def menu():
    st.page_link(".\home.py", label="| Home")
    st.page_link(".\registro.py", label="| Registro")
    st.page_link(".\resumo.py", label="| Resumo")
    st.page_link(".\extrato.py", label="| Extrato")