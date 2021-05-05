#!/usr/bin/env python

'''

Autor: Cauê Emilio de Moraes
Algoritmo para extração de dados de página web (link: http://www.ans.gov.br/prestadores/tiss-troca-de-informacao-de-saude-suplementar)
Versão da biblioteca: tabula-py V. 2.2.0 (Java precisa estar instalado e no 'path' do sistema)
Atualização: 04/05/21

'''
import os
from zipfile import ZipFile as zf
import tabula as tb

arquivo = 'http://www.ans.gov.br/images/stories/Plano_de_saude_e_Operadoras/tiss/Padrao_tiss/tiss3/Padrão_TISS_Componente_Organizacional_202103.pdf'
tabelas = tb.read_pdf(arquivo,pages ='79-85', multiple_tables=True)

pasta = 'Tabelas em csv'
if not os.path.isdir(pasta):
    os.mkdir(pasta)

for cada, tabela in enumerate(tabelas, start=30):
    if cada == 30:
        tabela.to_csv(os.path.join(pasta, f"tabela_30.csv"), index=False)
    elif 30<cada<37:
        with open(os.path.join(pasta,'tabela_31.csv'),'a') as tabela_31:
            tabela_31.write(tabela.to_csv(index=False))
    else:
        tabela.to_csv(os.path.join(pasta, f"tabela_32.csv"), index=False)

nome_zip = 'Teste_Intuitive_Care_{Caue_Emilio_de_Moraes}.zip'
with zf(nome_zip, 'w') as csvzip:
   for nome_pasta, subpastas, csvs in os.walk(pasta):
       for csv in csvs:
           csvzip.write(os.path.join(nome_pasta, csv))
