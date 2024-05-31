import streamlit as st

def menu():
    st.sidebar.page_link(".\pages\home.py", label="| Home")
    st.sidebar.page_link(".\pages\\registro.py", label="| Registro")
    st.sidebar.page_link(".\pages\\resumo.py", label="| Resumo")
    st.sidebar.page_link(".\pages\extrato.py", label="| Extrato")