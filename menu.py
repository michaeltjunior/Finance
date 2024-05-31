import streamlit as st

def menu():
    st.sidebar.page_link(".\pages\home.py", label="| Home")
    st.sidebar.page_link(".\pages\\registro.py", label="| Registro")