import streamlit as st
from menu import menu

menu()

def busca_saldos():
    tipos = json.loads(json.dumps(requests.get("https://intelliseven.com.br/meteo/finance/saldos").json()))

    for tipo in tipos:
        lista_tipos_movimento.append(tipo['tipo'])
    st.session_state['tipos_movimento'] = lista_tipos_movimento

st.title("| Resumo")