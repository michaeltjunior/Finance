import streamlit as st
from menu import menu
from image_loader import render_image

menu()

#render_image(".\logo.jpg")
st.image('logo.jpg')
