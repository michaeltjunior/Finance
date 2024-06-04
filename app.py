import streamlit as st

import os, sys
script_path = os.path.realpath(os.path.dirname(__name__))
os.chdir(script_path)
sys.path.append("..")

from menu import menu
#from image_loader import render_image

#render_image(".\pages\logo.jpg")
st.image('.\pages\logo.jpg')

menu()