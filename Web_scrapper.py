#!/usr/bin/env python

'''

Autor: Cauê Emilio de Moraes
Algoritmo para extração de dados de página web (link: http://www.ans.gov.br/prestadores/tiss-troca-de-informacao-de-saude-suplementar)
Versões das bibliotecas: requests V. 2.25.1 / beautifulsoup4 V. 4.9.0
Atualização: 04/05/21

'''

from bs4 import BeautifulSoup as bs
import requests

def le_html(url,formato='estruturado'):
    '''
        Função que retorna o conteúdo HTML da página, podendo ou não ser estrururado pela biblioteca BeautifulSoup e acusa falha na requisição
        Recebe formato 'download' caso seja utilizado para baixar os conteúdos da página e não necessita de formato para retornar um HTML estruturado 
    '''
    html = requests.get(url)

    if html.status_code != 200:
        print(" -- Falha na requisição --")
    else:
        conteudo_pagina = html.content
        
    conteudo = bs(conteudo_pagina,'html.parser') #Estrutura o conteúdo
    
    if formato=='estruturado':
        return conteudo
    elif formato=='download':
        return conteudo_pagina
    else:
        return print('formato inválido, deixe em branco ou escolha "pdf"')

def baixar_pdf(nome_arquivo,url_pdf):
    '''
        Função feita para baixar arquivos em .pdf da página escolhida
        Recebe o nome para o arquivo e o link de onde o mesmo deve ser baixado
    '''
    print("Baixando arquivo")
    with open(nome_arquivo, 'wb') as pdf:
        pdf.write(le_html(url_pdf,'download'))
    print("Arquivo {0} baixado".format(nome_arquivo))


    
url_base = 'http://www.ans.gov.br'
url_dado = url_base+'/prestadores/tiss-troca-de-informacao-de-saude-suplementar' #Url a ser acessado

pagina = le_html(url_dado)
link_atual = pagina.find('a',{'class':'alert-link'}) #Encontra o link de onde estão os dados atuais
url_atual = url_base+link_atual['href'] #Novo link a ser utilizado

pagina_atual = le_html(url_atual)
link_pdf = pagina_atual.select("a[href$='.pdf']")[0]
url_pdf = url_base+link_pdf['href'] #link do PDF a ser baixado

baixar_pdf("padrao_tiss_componente_organizacional_201902.pdf",url_pdf)
