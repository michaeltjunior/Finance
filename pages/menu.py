import streamlit as st

def menu():
    st.sidebar.page_link(".\home.py", label="| Home")
    st.sidebar.page_link(".\\registro.py", label="| Registro")
    st.sidebar.page_link(".\\resumo.py", label="| Resumo")
    st.sidebar.page_link(".\extrato.py", label="| Extrato")