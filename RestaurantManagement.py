import tkinter as tk
import tkinter.ttk as ttk
import os
import psycopg2
import RestaurantManagement  as sW
from tkinter.ttk import Combobox
from tkinter.ttk import Label
from datetime import date
import hashlib 
today = date.today()

LARGE_FONT= ("Verdana", 12)
restaurante = 0
admin = 0
Prato = ''
    
class ecra_entrada(tk.Tk):

    def __init__(self, *args, **kwargs):
        self._frame = None
        tk.Tk.__init__(self, *args, **kwargs)
        self.title('R & R - Base de dados II')
        self.container = tk.Frame(self.geometry("700x700+500+100"))
        self.resizable(0,0)
        self.container.pack(side="top", fill="both", expand = True)

        self.container.grid_rowconfigure(0, weight=1)
        self.container.grid_columnconfigure(0, weight=1)
            
        self.show_frame(Inicio)

    def show_frame(self, frame_class):            
        new_frame = frame_class(self.container, self)
        if self._frame is not None:
            self._frame.forget()
        self._frame = new_frame
        new_frame.grid(row=0, column=0, sticky="nsew")

    def show_detalhes_prato(self, p):
        global Prato 
        Prato = p
        new_frame = Detalhes(self.container, self)
        if self._frame is not None:
            self._frame.forget()
        self._frame = new_frame
        new_frame.grid(row=0, column=0, sticky="nsew")
        return Prato
 
    def endApp(self):
        os._exit(1) 
          
    def receita_diaria(self, d):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_receita_diaria('" + d + "'," + str(restaurante) + ")")     
        v = cur.fetchone()
        vv = str(v).replace("('", "")
        vvv = str(vv).replace("',)", "")
        cur.close()
        conn.close()   
        if vvv == "(None,)":
            vvv = "0 €"  
        return vvv

    def receita_ultimos_sete_dias(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_receita_ultimos_sete_dias(" + str(restaurante) + ")")     
        v = cur.fetchone()
        vv = str(v).replace("('", "")
        vvv = str(vv).replace("',)", "")
        cur.close()
        conn.close()     
        if vvv == "(None,)":
            vvv = "0 €"
        return vvv

    def add_ingrediente(self, prato, ing): 
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("CALL add_ingrediente('"+ prato + "','" + ing + "')")
        cur.close()
        conn.close() 
        self.show_frame(Ementas) 
    
    def ver_pratos(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT * FROM ver_pratos() as (Pratos VARCHAR(30))')
        vvv = []
        for v in cur.fetchall():
            vv = str(v).replace("('", "")
            vvv.append(str(vv).replace("',)", ""))
        cur.close()
        conn.close() 
        return vvv

    def ver_ementa_pratos(self, r):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True    
        cur = conn.cursor()
        cur.execute("select * from ver_ementa_pratos(" + str(r) + ")")
        vvv = []
        for v in cur.fetchall():
            vv = str(v).replace("('", "")
            vvv.append(str(vv).replace("',)", ""))
        cur.close()
        conn.close() 
        return vvv

    def ver_mesas_restaurante_estado(self, r, e):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_mesas_restaurante_estado(" + str(r) + "," + str(e) + ")")
        vvv = cur.fetchall()
        cur.close()
        conn.close() 
        return vvv

    def ver_mesas_restaurante(self, r):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT ver_mesas_restaurante(' + str(r) + ')')
        vvv = cur.fetchall()
        cur.close()
        conn.close() 
        return vvv

    def ver_funcionarios_restaurante(self, r):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT ver_funcionarios(' + str(r) + ')')
        vvv = cur.fetchall()
        cur.close()
        conn.close() 
        return vvv

    def ver_nome_produtos(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT ver_nome_produtos()')
        vvv = []
        for v in cur.fetchall():
            vv = str(v).replace("('", "")
            vvv.append(str(vv).replace("',)", ""))        
        cur.close()
        conn.close() 
        return vvv
    
    def verifica_Numeros(self, s):
        try:
            float(s)
        except ValueError:
            return False
        return True

class Inicio(tk.Frame):

    def login(self, user, password):
        global admin
        global restaurante
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        cur = conn.cursor()
        enc_pass = hashlib.md5(password.encode()).hexdigest()
        cur.execute("select * from login('" + user + "','" + str(enc_pass) + "')")
        result = cur.fetchone()
        cur.close()
        conn.close()
        if result is not None:
            admin = result[0]
            restaurante = result[1]
            return True
        else:
            return False

    def iniciar(self, user, password, controller):
        verificacao = self.login(user, password)
        if verificacao != True:
            self.label_ERRO.config(text="Utilizador e/ou password inválidos!")
            return 0       
        if admin == 1:     
            controller.show_frame(Ementas)
        elif admin == 0:
            controller.show_frame(Ementas_func)

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        label_titulo = tk.Label(self, text="R&R", font=("Helvetica", 36))
        label_titulo.place(x=297, y=50)
        label_subtitulo = tk.Label(self, text="login", font=("Helvetica", 20))
        label_subtitulo.place(x=320, y=110)

        label_user = tk.Label(self, text="Utilizador:", font=LARGE_FONT)
        label_user.place(x=130, y=250)
        user = tk.Entry(self, font=LARGE_FONT)
        user.place(relwidth=0.40, rely=0.01, relheight=0.05, y=240, x=240)
        user.focus_set()
        label_pass = tk.Label(self, text="Password:", font=LARGE_FONT)
        label_pass.place(x=130, y=330)
        password = tk.Entry(self, font=LARGE_FONT, show="*")
        password.place(relwidth=0.40, rely=0.01, relheight=0.05, y=320, x=240)
        password.focus_set()

        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=210, y=400)
        self.label_ERRO.config(fg="red")

        button_entrar = tk.Button(self, text="Entrar",command=lambda: self.iniciar(user.get(), password.get(), controller))
        button_entrar.place(x=260, y=500)
        button_entrar.config(width=25,height=2, background="#87E193", fg="black")
        button_criar = tk.Button(self, text="Criar conta",command=lambda: controller.show_frame(CriarConta))
        button_criar.place(x=260, y=550)
        button_criar.config(width=25,height=2, background="#BDB76B", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=260, y=600)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

class Inserir_Prato(tk.Frame):

    def ver_ingredientes_restantes(self, prato):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_ingredientes_restantes('" + prato + "')")
        vvv = cur.fetchall()
        cur.close()
        conn.close() 
        return vvv
    
    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Criação de um prato", font=("Helvetica", 20))
        label_titulo.place(x=220, y=110)
        v = controller.ver_pratos()
        label_pratosExistentes = tk.Label(self, text="Pratos existentes:", font=LARGE_FONT)
        label_pratosExistentes.place(x=110, y=250)
        combo=Combobox(self, values=v)
        combo.place(x=330, y = 250)
        combo.config(width=30,height=20)
        label_prato = tk.Label(self, text="Nome prato:", font=LARGE_FONT)        #Escolher nome do prato
        label_prato.place(x=110, y=300)
        prato = tk.Entry(self, font=30)
        prato.place(y=300, x=330)
        prato.focus_set()
        label_preco = tk.Label(self, text="Preço:", font=LARGE_FONT)        #Escolher Preço
        label_preco.place(x=110, y=350)
        preco = tk.Entry(self, font=30)
        preco.place(y=350, x=330)
        preco.focus_set()
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=190, y=400)
        self.label_ERRO.config(fg="red")

        button_gravar = tk.Button(self, text="Criar prato", command=lambda: self.criar_prato(prato.get(), preco.get(), controller))
        button_gravar.place(x=260, y=650)
        button_gravar.config(width=25,height=2, background="#87E193", fg="white")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Consultar_Pratos))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def criar_prato(self, prato, preco, controller):
        if prato != '':
            if not controller.verifica_Numeros(prato):
                if preco != '':
                    if controller.verifica_Numeros(preco):
                        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                        conn.autocommit = True
                        cur = conn.cursor()
                        cur.execute("CALL criar_prato('"+ prato + "','" + preco + "')")
                        cur.close()
                        conn.close() 
                        controller.show_frame(Ementas) 
                        return True
        self.label_ERRO.config(text="É necessário preencher todos os campos devidamente!")
        return False

class Detalhes(tk.Frame):

    def ver_ingredientes_restantes(self, prato):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_ingredientes_restantes('" + prato + "')")
        vvv = []
        for v in cur.fetchall():
            vv = str(v).replace("('", "")
            vvv.append(str(vv).replace("',)", ""))           
        cur.close()
        conn.close() 
        return vvv
    
    def ver_detalhes(self, prato):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM ver_detalhes_prato('" + prato + "')")
        vvv = cur.fetchall()     
        cur.close()
        conn.close() 
        return vvv

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_pratosExistentes = tk.Label(self, text=str(Prato), font=("Helvetica", 20))
        label_pratosExistentes.place(x=50, y=50)

        colunas = ('Preço', 'Ingredientes', 'Alergias')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=25, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=325)
        vvv = self.ver_detalhes(Prato)
        for data in vvv:
            self.lista.insert("", "end", values=data)

        if admin == 1:
            label_ing = tk.Label(self, text="Ingredientes:", font=LARGE_FONT)        #Escolher ingredientes
            label_ing.place(x=140, y=250)
            ingredientes = self.ver_ingredientes_restantes(Prato)
            ing = ttk.Combobox(self, values = ingredientes)
            ing.place(x = 270, y = 250)
            ing.config(width=30,height=20)
            button_inserir = tk.Button(self, text="+", command=lambda: controller.add_ingrediente(Prato, ing.get()))
            button_inserir.place(x=500, y=250)
            button_inserir.config(width=2,height=1, fg="black")
            label_preco = tk.Label(self, text="Preço:", font=LARGE_FONT)        #Escolher Preço
            label_preco.place(x=200, y=150)
            preco = tk.Entry(self, font=30)
            preco.place(y=150, x=270)
            preco.focus_set()
            self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
            self.label_ERRO.place(x=180, y=575)
            self.label_ERRO.config(fg="red")
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
            button_gravar = tk.Button(self, text="Atualizar preço", command=lambda: self.atualizar_preco(preco.get(), controller))
            button_gravar.place(x=260, y=650)
            button_gravar.config(width=25,height=2, background="#87E193", fg="black")
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def atualizar_preco(self, preco, controller):
        if preco != '':
            if controller.verifica_Numeros(preco):
                conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                conn.autocommit = True
                cur = conn.cursor()
                cur.execute("CALL atualizarpreco_prato('"+ Prato + "','" + preco + "')")
                cur.close()
                conn.close() 
                controller.show_frame(Ementas) 
                return True
        self.label_ERRO.config(text="Para atualizar o preço, é necessário \npreencher o campo com um valor adequado")
        return False

class Gerir_Reservas(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent) 
        button_pratos = tk.Button(self, text="Fazer Reserva",command=lambda: controller.show_frame(Fazer_Reserva))
        button_pratos.place(x=170, y=300)
        button_pratos.config(width=20,height=5, fg="black")
        button_outros = tk.Button(self, text="Ver Reservas",command=lambda: controller.show_frame(Ver_Reservas))
        button_outros.place(x=415, y=300)
        button_outros.config(width=20,height=5, fg="black")

        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))

        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

class Fazer_Reserva(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Fazer reserva:", font=LARGE_FONT)
        label_titulo.place(x=275, y=25)
        label_data = tk.Label(self, text="Data:", font=LARGE_FONT)
        label_data.place(x=150, y=125)
        combo_dia=Combobox(self, values=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30'])
        combo_dia.place(x=350, y = 125, width=50)
        combo_mes=Combobox(self, values=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'])
        combo_mes.place(x=425, y = 125, width=50)
        combo_ano=Combobox(self, values=['2020'])
        combo_ano.place(x=500, y = 125, width=50)
        f = controller.ver_funcionarios_restaurante(restaurante)        #Escolher funcionário
        label_f = tk.Label(self, text="Funcionário:", font=LARGE_FONT)
        label_f.place(x=150, y=175)
        combo_f=Combobox(self, values=f)
        combo_f.place(x=350, y = 175)
        label_npessoas = tk.Label(self, text="Número de pessoas:", font=LARGE_FONT)        #Escolher n_pessoas
        label_npessoas.place(x=150, y= 225)
        combo_npessoas=Combobox(self, values=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'])
        combo_npessoas.place(x=350, y = 225, width=50)
        label_cliente = tk.Label(self, text="Nome cliente:", font=LARGE_FONT)        #nome cliente
        label_cliente.place(x=150, y=275)
        cliente = tk.Entry(self, font=20)
        cliente.place(relwidth=0.30, rely=0.01, relheight=0.04, y=275, x=350)
        cliente.focus_set()
        label_obs = tk.Label(self, text="Observações:", font=LARGE_FONT)        #Observações
        label_obs.place(x=150, y=325)
        obs = tk.Entry(self, font=20)
        obs.place(relwidth=0.30, rely=0.01, relheight=0.1, y=325, x=350)
        obs.focus_set()
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=130, y=500)
        self.label_ERRO.config(fg="red")
        #Fazer reserva
        button_inserir = tk.Button(self, text="Fazer Reserva", command=lambda: self.fazer_reserva(combo_dia.get(), combo_mes.get(), combo_ano.get(), combo_npessoas.get(), cliente.get(), combo_f.get(), obs.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="black")
        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def fazer_reserva(self, dia, mes, ano, npessoas, cliente, funcionario, observacoes, controller):
        if dia != '':
            if mes != '':
                if ano != '':
                    if npessoas != '':
                        if cliente != '':
                            if funcionario != '':
                                conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                                conn.autocommit = True
                                cur = conn.cursor()
                                cur.execute("CALL criar_reserva('" + str(dia) + "-" + str(mes) + "-" + str(ano) + "'," + str(npessoas) + ",'" + cliente + "','" + funcionario + "'," + str(restaurante) + ",'" +  observacoes + "')")
                                cur.close()
                                conn.close() 
                                controller.show_frame(Ementas)
                                return True
        self.label_ERRO.config(text="Apenas o campo 'Observações' é facultativo!\nNo entanto também deve ser preenchido mencionando\n a hora e outros aspetos relevantes da reserva.")
        return False

class Ver_Reservas(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label = tk.Label(self, text="Consultar reservas", font=LARGE_FONT)
        label.place(x=290, y=50)
        colunas = ('Data', 'Cliente', 'Pessoas', 'Funcionário', 'Observações')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=15, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=200)
        vvv = self.ver_reservas()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")
    
    def ver_reservas(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM ver_reservas("+ str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close() 
        return v
        
class Registar_pedido_pratos(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Registar pedido", font=("Helvetica", 20))
        label_titulo.place(x=250, y=110)
        tipo_refeicao = 'Prato'
        m = controller.ver_mesas_restaurante(restaurante)         #Escolher mesa
        label_m = tk.Label(self, text="Mesa:", font=LARGE_FONT)
        label_m.place(x=150, y=250)
        combo_m=Combobox(self, values=m)
        combo_m.place(x=350, y = 250)
        f = controller.ver_funcionarios_restaurante(restaurante)        #Escolher funcionário
        label_f = tk.Label(self, text="Funcionário:", font=LARGE_FONT)
        label_f.place(x=150, y=300)
        combo_f=Combobox(self, values=f)
        combo_f.place(x=350, y = 300)
        p = controller.ver_ementa_pratos(restaurante)        #Escolher produto
        label_p = tk.Label(self, text="Prato:", font=LARGE_FONT)
        label_p.place(x=150, y= 350)
        combo_p=Combobox(self, values=p)
        combo_p.place(x=350, y = 350)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=125, y=500)
        self.label_ERRO.config(fg="red")

        button_inserir = tk.Button(self, text="Inserir na conta", command=lambda: self.registar_pedido(tipo_refeicao, combo_p.get(), combo_m.get(), combo_f.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="black")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Registar_pedido))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def registar_pedido(self, tr, prod, mesa, funcionario, controller):
        if prod != '':
            if mesa != '':
                if funcionario != '':
                    conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                    conn.autocommit = True
                    cur = conn.cursor()
                    cur.execute("CALL registar_pedido('" + tr + "','" + prod + "'," + str(mesa) + ",'" + funcionario + "')")
                    cur.close()
                    conn.close() 
                    controller.show_frame(Ementas)
                    return True
        self.label_ERRO.config(text="É necessário preencher todos os campos devidamente!")
        return False

class Registar_pedido_outros(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Registar pedido", font=("Helvetica", 20))
        label_titulo.place(x=250, y=110)
        tipo_refeicao = 'outro'
        m = controller.ver_mesas_restaurante(restaurante)        #Escolher mesa
        label_m = tk.Label(self, text="Mesa:", font=LARGE_FONT)
        label_m.place(x=150, y=250)
        combo_m=Combobox(self, values=m)
        combo_m.place(x=350, y = 250)
        f = controller.ver_funcionarios_restaurante(restaurante)        #Escolher funcionário
        label_f = tk.Label(self, text="Funcionário:", font=LARGE_FONT)
        label_f.place(x=150, y=300)
        combo_f=Combobox(self, values=f)
        combo_f.place(x=350, y = 300)
        p = controller.ver_nome_produtos()         #Escolher produto
        label_p = tk.Label(self, text="Produto:", font=LARGE_FONT)
        label_p.place(x=150, y=350)
        combo_p=Combobox(self, values=p)
        combo_p.place(x=350, y = 350)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=125, y=500)
        self.label_ERRO.config(fg="red")

        button_inserir = tk.Button(self, text="Inserir na conta", command=lambda: self.registar_pedido(tipo_refeicao, combo_p.get(), combo_m.get(), combo_f.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="black")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Registar_pedido))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    
    def registar_pedido(self, tr, prod, mesa, funcionario, controller):
        if prod != '':
            if mesa != '':
                if funcionario != '':
                    conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                    conn.autocommit = True
                    cur = conn.cursor()
                    cur.execute("CALL registar_pedido('" + tr + "','" + prod + "'," + str(mesa) + ",'" + funcionario + "')")
                    cur.close()
                    conn.close() 
                    controller.show_frame(Ementas)
                    return True
        self.label_ERRO.config(text="É necessário preencher todos os campos devidamente!")
        return False

class Registar_pedido(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        button_pratos = tk.Button(self, text="PRATOS",command=lambda: controller.show_frame(Registar_pedido_pratos))
        button_pratos.place(x=170, y=300)
        button_pratos.config(width=20,height=5, fg="black")
        button_outros = tk.Button(self, text="OUTROS PRODUTOS",command=lambda: controller.show_frame(Registar_pedido_outros))
        button_outros.place(x=415, y=300)
        button_outros.config(width=20,height=5, fg="black")
        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

class Consultar_Pedidos(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label = tk.Label(self, text="Pedidos recentes", font=("Helvetica", 20))
        label.place(x=290, y=50)
        colunas = ('ID pedido', 'Produto', 'Data', 'Mesa', 'Funcionario')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=15, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=200)
        vvv = self.ver_pedidos()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        
        self.pedido = ''
        self.lista.bind('<<TreeviewSelect>>', self.selectItem)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=190, y=500)
        self.label_ERRO.config(fg="red")
        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        
        button_apagar = tk.Button(self, text="Cancelar pedido", command=lambda: self.cancelar_pedido(self.pedido, controller))
        button_apagar.place(x=260, y=650)
        button_apagar.config(width=25,height=2, background="#c4cbd5", fg="black")
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black") 
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")
        
    def ver_pedidos(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM ver_pedidos(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close()     
        return v

    def selectItem(self, event):
        for item in self.lista.selection():
            item_text = self.lista.item(item, 'values')
            vvv = []
            x = 0
            for i in item_text: 
                if (i == '(' or i == "'") and x <= 2:
                    x = x + 1
                else:
                    vvv.append(i) 
                    break       
            vv = str(vvv).replace("['", "")
            p = str(vv).replace("']", "")
            self.pedido = p

    def cancelar_pedido(self, pedido, controller):
        if pedido != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL cancelar_pedido("+ str(pedido) + ")")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas) 
            return True
        self.label_ERRO.config(text="É necessário selecionar um pedido!")
        return False

class Registar_fatura(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Registo de fatura", font=("Helvetica", 20))
        label_titulo.place(x=245, y=50)
        m = controller.ver_mesas_restaurante_estado(restaurante, 1)        #Escolher mesa
        label_m = tk.Label(self, text="Mesa:", font=LARGE_FONT)
        label_m.place(x=200, y=200)
        combo_m=Combobox(self, values = m)
        combo_m.place(x=300, y = 200)
        label_nif = tk.Label(self, text="NIF:", font=LARGE_FONT)
        label_nif.place(x=50, y= 300)
        nif = tk.Entry(self, font=30)
        nif.place(relwidth=0.30, rely=0.01, relheight=0.04, y=295, x=100)
        nif.focus_set()
        label_cliente = tk.Label(self, text="Nº Cliente:", font=LARGE_FONT)
        label_cliente.place(x=340, y= 300)
        cliente = tk.Entry(self, font=30)
        cliente.place(relwidth=0.30, rely=0.01, relheight=0.04, y=295, x=440)
        cliente.focus_set()
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=190, y=500)
        self.label_ERRO.config(fg="red")

        #Inserir produto
        button_inserir = tk.Button(self, text="Registar fatura", command=lambda: self.registar_fatura(combo_m.get(), nif.get(), cliente.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="black")
        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def registar_fatura(self, m, nif, cliente, controller):
        if m != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            if nif == "":
                if cliente == "":
                    cur.execute("CALL add_fatura_s_nif(0," + str(m) + "," + str(restaurante) + ")")
                else:
                    cur.execute("CALL add_fatura_s_nif(" + str(cliente) + "," + str(m) + "," + str(restaurante) + ")")
            else:
                cur.execute("CALL add_fatura_c_nif(" + str(nif) + "," + str(m) + "," + str(restaurante) + ")")      
            cur.close()
            conn.close()             
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar uma mesa para proceder\nao registo da fatura!")
        return False

class Consultar_Faturas_semana(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label = tk.Label(self, text="Faturas - Últimos 7 dias", font=LARGE_FONT)
        label.place(x=25, y=25)
        colunas = ('ID fatura', 'Cliente', 'NIF', 'Data', 'Produto', 'Preço', 'Estado')
        lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            lista.heading(col, text=col, anchor='center')
            lista.column(col, width=35, anchor='center')
        lista.grid(row=1, column=0, columnspan=2, ipadx=200, padx=25, pady=75)  
        vvv = self.ver_faturas_semana()
        for data in vvv:
            lista.insert("", "end", values=data)  

        button_pagamento = tk.Button(self, text="Efetuar pagamento", command=lambda: controller.show_frame(Confirmar_Pagamento))
        button_pagamento.place(x=260, y=650)
        button_pagamento.config(width=25,height=2, background="#87E193", fg="black")
        if admin == 1:
            date = today.strftime("%Y-%m-%d")   
            rd = controller.receita_diaria(date)
            rs = controller.receita_ultimos_sete_dias()
            label_rd = tk.Label(self, text="Receita Diária: " + rd + " ", font=LARGE_FONT)
            label_rd.place(x=25, y=350)   
            label_rs = tk.Label(self, text="Receita últimos 7 dias: " + rs + " ", font=LARGE_FONT)
            label_rs.place(x=25, y=400) 
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def ver_faturas_semana(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM ver_faturas_semana(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close()     
        return v

class Consultar_Faturas(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label = tk.Label(self, text="Faturas - Desde o ínicio", font=LARGE_FONT)
        label.place(x=25, y=25)
        colunas = ('ID fatura', 'Cliente', 'NIF', 'Data', 'Produto', 'Preço', 'Estado')
        lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            lista.heading(col, text=col, anchor='center')
            lista.column(col, width=35, anchor='center')
        lista.grid(row=1, column=0, columnspan=2, ipadx=200, padx=25, pady=75)
        
        vvv = self.ver_faturas()
        for data in vvv:
            lista.insert("", "end", values=data)
           
        button_pagamento = tk.Button(self, text="Efetuar pagamento", command=lambda: controller.show_frame(Confirmar_Pagamento))
        button_pagamento.place(x=260, y=650)
        button_pagamento.config(width=25,height=2, background="#87E193", fg="black")
        if admin == 1:
            date = today.strftime("%Y-%m-%d")   
            rd = controller.receita_diaria(date)
            rs = controller.receita_ultimos_sete_dias()
            rma = self.receita_media_almocos()
            rmj = self.receita_media_jantares()
            rmd = self.receita_media_diaria()
            label_rd = tk.Label(self, text="Receita Diária: " + rd + " ", font=LARGE_FONT)
            label_rd.place(x=25, y=350)   
            label_rs = tk.Label(self, text="Receita últimos 7 dias: " + rs + " ", font=LARGE_FONT)
            label_rs.place(x=25, y=400)   
            label_rma = tk.Label(self, text="Receita Média almoços: " + rma + " ", font=LARGE_FONT)
            label_rma.place(x=25, y=450)   
            label_rmj = tk.Label(self, text="Receita Média jantares: " + rmj + " ", font=LARGE_FONT)
            label_rmj.place(x=25, y=500)   
            label_rmd = tk.Label(self, text="Receita Média diária: " + rmd + " ", font=LARGE_FONT)
            label_rmd.place(x=25, y=550)   
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def ver_faturas(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM ver_faturas(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close()     
        return v
    
    def receita_media_almocos(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_receita_media_almocos(" + str(restaurante) + ")")     
        v = cur.fetchone()
        vv = str(v).replace("('", "")
        vvv = str(vv).replace("',)", "")
        cur.close()
        conn.close()     
        if vvv == "(None,)":
            vvv = "0 €"
        return vvv

    def receita_media_jantares(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_receita_media_jantares(" + str(restaurante) + ")")     
        v = cur.fetchone()
        vv = str(v).replace("('", "")
        vvv = str(vv).replace("',)", "")
        cur.close()
        conn.close()     
        if vvv == "(None,)":
            vvv = "0 €"
        return vvv

    def receita_media_diaria(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT ver_receita_media_diaria(" + str(restaurante) + ")")     
        v = cur.fetchone()
        vv = str(v).replace("('", "")
        vvv = str(vv).replace("',)", "")
        cur.close()
        conn.close()     
        if vvv == "(None,)":
            vvv = "0 €"
        return vvv

class Confirmar_Pagamento(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label = tk.Label(self, text="Faturas - Por pagar", font=LARGE_FONT)
        label.place(x=25, y=25)
        colunas = ('ID fatura', 'Cliente', 'NIF', 'Data', 'Produto', 'Preço')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=40, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=200, padx=25, pady=75)
        vvv = self.ver_faturas_por_pagar()
        for data in vvv:
            self.lista.insert("", "end", values=data)

        self.prod = ''
        self.lista.bind('<<TreeviewSelect>>', self.selectItem)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=190, y=400)
        self.label_ERRO.config(fg="red")

        button_pagamento = tk.Button(self, text="Efetuar pagamento", command=lambda: self.confirmar_pagamento(self.prod, controller))
        button_pagamento.place(x=260, y=650)
        button_pagamento.config(width=25,height=2, background="#87E193", fg="black")
        if admin == 1:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def selectItem(self, event):
        for item in self.lista.selection():
            item_text = self.lista.item(item, 'values')
            vvv = []
            x = 0
            for i in item_text: 
                if (i == '(' or i == "'") and x <= 2:
                    x = x + 1
                else:
                    vvv.append(i) 
                    break       
            vv = str(vvv).replace("['", "")
            p = str(vv).replace("']", "")
            self.prod = p

    def ver_faturas_por_pagar(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM ver_faturas_por_pagar(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close()     
        return v

    def confirmar_pagamento(self, prod, controller):
        if prod != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL registar_pagamento(" + str(prod) + ")")
            cur.close()
            conn.close()     
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="É necessário selecionar uma fatura!")
        return False

class Inserir_Produtos(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Criação de um produto", font=("Helvetica", 20))
        label_titulo.place(x=220, y=25)
        label_produto = tk.Label(self, text="Nome produto:", font=LARGE_FONT)        #Escolher nome do produto
        label_produto.place(x=130, y=100)
        produto = tk.Entry(self, font=30)
        produto.place(relwidth=0.40, rely=0.01, relheight=0.05, y=90, x=310)
        produto.focus_set()
        label_preco = tk.Label(self, text="Preço:", font=LARGE_FONT)        #Escolher Preço
        label_preco.place(x=130, y=150)
        preco = tk.Entry(self, font=30)
        preco.place(relwidth=0.40, rely=0.01, relheight=0.05, y=140, x=310)
        preco.focus_set()
        label_zconf = tk.Label(self, text="Zona de confeção:", font=LARGE_FONT)        #Escolher zona confeção
        label_zconf.place(x=130, y=200)
        combo_zconf=Combobox(self, values=['Cozinha', 'Balcão'])
        combo_zconf.place(x=310, y = 200)
        label_tp = tk.Label(self, text="Tipo de produto:", font=LARGE_FONT)             #Escolher tipo de produto
        label_tp.place(x=130, y=250)
        combo_tp=Combobox(self, values= ['Bebida', 'Peixe', 'Carne', 'Acompanhamento', 'Fruta', 'Salgados', 'Doces'])
        combo_tp.place(x=310, y = 250)
        label_tr = tk.Label(self, text="Tipo de refeição:", font=LARGE_FONT)            #Escolher tipo de refeicao
        label_tr.place(x=130, y=300)
        combo_tr=Combobox(self, values=['Prato', 'Sobremesa', 'Entradas', 'Snack', 'Vegetariano'])
        combo_tr.place(x=310, y = 300)
        label_iva = tk.Label(self, text="IVA:", font=LARGE_FONT)        #Escolher IVA
        label_iva.place(x=130, y=350)
        combo_iva=Combobox(self, values=['0.23', '0.13', '0.06'])
        combo_iva.place(x=310, y = 350)
        label_quantidade = tk.Label(self, text="Quantidade:", font=LARGE_FONT)        #Escolher quantidade que vai ser posta à venda
        label_quantidade.place(x=130, y=400)
        quantidade = tk.Entry(self, font=30)
        quantidade.place(relwidth=0.40, rely=0.01, relheight=0.05, y=390, x=310)
        quantidade.focus_set()
        label_min = tk.Label(self, text="Stock Mínimo:", font=LARGE_FONT)        #Escolher quantidade minima
        label_min.place(x=130, y=450)
        minimo = tk.Entry(self, font=30)
        minimo.place(relwidth=0.40, rely=0.01, relheight=0.05, y=440, x=310)
        minimo.focus_set()
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=130, y=550)
        self.label_ERRO.config(fg="red")

        button_inserir = tk.Button(self, text="Inserir", command=lambda: self.criar_produto(produto.get(), preco.get(), combo_zconf.get(), combo_tp.get(), combo_tr.get(), combo_iva.get(), quantidade.get(), minimo.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="black")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ver_Produtos))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def criar_produto(self, produto, preco, zconf, tp, tr, iva, quant, minimo, controller):
        if produto != '' and preco != '' and zconf != '' and tp != '' and tr != '' and iva != '' and quant != '' and minimo != '':
            if not controller.verifica_Numeros(produto) and controller.verifica_Numeros(preco) and controller.verifica_Numeros(quant) and controller.verifica_Numeros(minimo):
                conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                conn.autocommit = True
                cur = conn.cursor()
                cur.execute("CALL criar_produto('"+ zconf + "','" + tr + "','" + tp + "','" + str(preco) + "','" + str(iva) + "'," + str(quant) + ",'" + produto + "'," + str(minimo) + ")")
                cur.close()
                conn.close() 
                controller.show_frame(Ementas)
                return True
        self.label_ERRO.config(text="Devem ser preenchidos todos os campos devidamente!")
        return False

class Inserir_Prato_Ementa(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Inserir prato na\nEmenta", font=("Helvetica", 20))
        label_titulo.place(x=250, y=50)
        v = controller.ver_pratos()        #Ver pratos existentes
        label_pratosExistentes = tk.Label(self, text="Pratos existentes:", font=LARGE_FONT)
        label_pratosExistentes.place(x=150, y=200)
        combo_pratos=Combobox(self, values=v)
        combo_pratos.place(x=350, y = 200)
        label_tr = tk.Label(self, text="Tipo de refeição:", font=LARGE_FONT)        #Escolher tipo de refeicao
        label_tr.place(x=150, y=300)
        combo_tr=Combobox(self, values=['Almoço', 'Jantar'])
        combo_tr.place(x=350, y = 300)
        label_ds = tk.Label(self, text="Dia da semana:", font=LARGE_FONT)   #dia da semana
        label_ds.pack(pady=30,padx=2)
        label_ds.place(x=150, y=400)
        combo_ds=Combobox(self, values=['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'])
        combo_ds.place(x=350, y = 400)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=200, y=500)
        self.label_ERRO.config(fg="red")

        button_inserir = tk.Button(self, text="Inserir", command=lambda: self.inserir_prato_ementa(combo_pratos.get(), combo_tr.get(), combo_ds.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="white")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Consultar_Ementa))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def inserir_prato_ementa(self, prato, descricao, diasemanal, controller):
        if prato != '' and descricao != '' and diasemanal != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL inserir_prato_ementa('"+ prato + "','" + descricao + "','" + diasemanal + "','" + str(restaurante) + "')")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas) 
            return True
        self.label_ERRO.config(text="Deve preencher todos os campos!")
        return False

class Associar_Alergia_Produto(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        label_titulo = tk.Label(self, text="Associar alergia\na produto", font=("Helvetica", 20))
        label_titulo.place(x=250, y=110)
        v = controller.ver_nome_produtos()        #Ver produtos existentes
        label_prodExistentes = tk.Label(self, text="Produto:", font=LARGE_FONT)
        label_prodExistentes.place(x=150, y=250)
        combo_prod=Combobox(self, values=v)
        combo_prod.place(x=350, y = 250)
        a = self.ver_nome_alergias()        #ver alergias
        label_a = tk.Label(self, text="Alergias:", font=LARGE_FONT)
        label_a.place(x=150, y=300)
        combo_a=Combobox(self, values=a)
        combo_a.place(x=350, y = 300)
        label_g = tk.Label(self, text="Gravidade:", font=LARGE_FONT)            #gravidade da alergia
        label_g.place(x=150, y=350)
        combo_g=Combobox(self, values=['1', '2', '3', '4', '5'])
        combo_g.place(x=350, y = 350)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=200, y=500)
        self.label_ERRO.config(fg="red")

        button_inserir = tk.Button(self, text="Inserir", command=lambda: self.associar_alergia_produto(combo_prod.get(), combo_a.get(), combo_g.get(), controller))
        button_inserir.place(x=260, y=650)
        button_inserir.config(width=25,height=2, background="#87E193", fg="black")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Consultar_Alergias))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def associar_alergia_produto(self, p, a, gravidade, controller):
        if p != '' and a != '' and gravidade != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL alergia_produtos('" + p + "','" + a + "','" + gravidade + "')")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve preencher todos os campos!")
        return False

    def ver_nome_alergias(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT ver_nome_alergias()')
        vvv = []
        for v in cur.fetchall():
            vv = str(v).replace("('", "")
            vvv.append(str(vv).replace("',)", ""))        
        cur.close()
        conn.close() 
        return vvv

class Ementas_func(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = tk.Label(self, text="Pedidos e Faturas", font=LARGE_FONT)
        label.place(x=30, y=20)

        button_registarFatura = tk.Button(self, text="Registar Fatura",command=lambda: controller.show_frame(Registar_fatura))
        button_registarFatura.place(x=25, y=50)
        button_registarFatura.config(width=20,height=5, fg="black")
        button_verFaturas7dias = tk.Button(self, text="Consultar faturas\n(últimos 7 dias)",command=lambda: (controller.show_frame(Consultar_Faturas_semana)))
        button_verFaturas7dias.place(x=180, y=50)
        button_verFaturas7dias.config(width=20,height=5, fg="black")
        button_verPedidos = tk.Button(self, text="Consultar Pedidos",command=lambda: controller.show_frame(Consultar_Pedidos))
        button_verPedidos.place(x=335, y=50)
        button_verPedidos.config(width=20,height=5, fg="black")
        button_registarPedido = tk.Button(self, text="Registar pedido",command=lambda: controller.show_frame(Registar_pedido))
        button_registarPedido.place(x=490, y=50)
        button_registarPedido.config(width=20,height=5, fg="black")
        button_confirmarPagamento = tk.Button(self, text="Confirmar pagamento",command=lambda: controller.show_frame(Confirmar_Pagamento))
        button_confirmarPagamento.place(x=25, y=150)
        button_confirmarPagamento.config(width=20,height=5, fg="black")
        button_verTodasFaturas = tk.Button(self, text="Consultar faturas\n(desde o ínicio)",command=lambda: controller.show_frame(Consultar_Faturas))
        button_verTodasFaturas.place(x=180, y=150)
        button_verTodasFaturas.config(width=20,height=5, fg="black")
        button_reservas = tk.Button(self, text="Reservas",command=lambda: controller.show_frame(Gerir_Reservas))
        button_reservas.place(x=335, y=150)
        button_reservas.config(width=20,height=5, fg="black")
    
        label = tk.Label(self, text="Gestão restaurante", font=LARGE_FONT)
        label.place(x=30, y=270)

        button_verEmenta = tk.Button(self, text="Consultar ementa",command=lambda: controller.show_frame(Consultar_Ementa))
        button_verEmenta.place(x=25, y=300)
        button_verEmenta.config(width=20,height=5, fg="black")
        button_verAlergias = tk.Button(self, text="Consultar alergias \ndos pratos",command=lambda: controller.show_frame(Consultar_Alergias))
        button_verAlergias.place(x=180, y=300)
        button_verAlergias.config(width=20,height=5, fg="black")
        button_verPratos = tk.Button(self, text="Consultar pratos",command=lambda: controller.show_frame(Consultar_Pratos))
        button_verPratos.place(x=335, y=300)
        button_verPratos.config(width=20,height=5, fg="black")
        button_verProdutos = tk.Button(self, text="Consultar produtos",command=lambda: controller.show_frame(Ver_Produtos))
        button_verProdutos.place(x=490, y=300)
        button_verProdutos.config(width=20,height=5, fg="black")

        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Inicio))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def gerar_xml(self):    
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT gravarXML("+str(restaurante)+")")
        resultado = cur.fetchone()
        r = str(resultado).replace("('", "")
        info = str(r).replace("',)", "")
        cur.close()
        conn.close() 
        arquivo = open('BackupDadosR&R.xml','w')
        arquivo.write(str(info))
        arquivo.close()

class Ementas(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = tk.Label(self, text="Pedidos e Faturas", font=LARGE_FONT)
        label.place(x=30, y=20)

        button_registarFatura = tk.Button(self, text="Registar Fatura",command=lambda: controller.show_frame(Registar_fatura))
        button_registarFatura.place(x=25, y=50)
        button_registarFatura.config(width=20,height=5, fg="black")
        button_verFaturas7dias = tk.Button(self, text="Consultar faturas\n(últimos 7 dias)",command=lambda: (controller.show_frame(Consultar_Faturas_semana)))
        button_verFaturas7dias.place(x=180, y=50)
        button_verFaturas7dias.config(width=20,height=5, fg="black")
        button_verPedidos = tk.Button(self, text="Consultar Pedidos",command=lambda: controller.show_frame(Consultar_Pedidos))
        button_verPedidos.place(x=335, y=50)
        button_verPedidos.config(width=20,height=5, fg="black")
        button_registarPedido = tk.Button(self, text="Registar pedido",command=lambda: controller.show_frame(Registar_pedido))
        button_registarPedido.place(x=490, y=50)
        button_registarPedido.config(width=20,height=5, fg="black")
        button_confirmarPagamento = tk.Button(self, text="Confirmar pagamento",command=lambda: controller.show_frame(Confirmar_Pagamento))
        button_confirmarPagamento.place(x=25, y=150)
        button_confirmarPagamento.config(width=20,height=5, fg="black")
        button_verTodasFaturas = tk.Button(self, text="Consultar faturas\n(desde o ínicio)",command=lambda: controller.show_frame(Consultar_Faturas))
        button_verTodasFaturas.place(x=180, y=150)
        button_verTodasFaturas.config(width=20,height=5, fg="black")
        button_reservas = tk.Button(self, text="Reservas",command=lambda: controller.show_frame(Gerir_Reservas))
        button_reservas.place(x=335, y=150)
        button_reservas.config(width=20,height=5, fg="black")
    
        label = tk.Label(self, text="Gestão restaurante", font=LARGE_FONT)
        label.place(x=30, y=270)

        button_verEmenta = tk.Button(self, text="Ementa",command=lambda: controller.show_frame(Consultar_Ementa))
        button_verEmenta.place(x=25, y=300)
        button_verEmenta.config(width=20,height=5, fg="black")
        button_verAlergias = tk.Button(self, text="Alergias",command=lambda: controller.show_frame(Consultar_Alergias))
        button_verAlergias.place(x=180, y=300)
        button_verAlergias.config(width=20,height=5, fg="black")
        button_verPratos = tk.Button(self, text="Pratos",command=lambda: controller.show_frame(Consultar_Pratos))
        button_verPratos.place(x=335, y=300)
        button_verPratos.config(width=20,height=5, fg="black")
        button_verProdutos = tk.Button(self, text="Produtos",command=lambda: controller.show_frame(Ver_Produtos))
        button_verProdutos.place(x=490, y=300)
        button_verProdutos.config(width=20,height=5, fg="black")
        button_verHEmenta = tk.Button(self, text="Consultar\nhistórico de ementa",command=lambda: controller.show_frame(Consultar_HistoricoEmenta))
        button_verHEmenta.place(x=25, y=400)
        button_verHEmenta.config(width=20,height=5, fg="black")
        button_gravarXML = tk.Button(self, text="Gravar XML",command=lambda: self.gerar_xml())
        button_gravarXML.place(x=180, y=400)
        button_gravarXML.config(width=20,height=5, fg="black")
        button_verPedidosConta = tk.Button(self, text="Ver pedidos de\ncriação de conta",command=lambda: controller.show_frame(Consultar_RegistoContas))
        button_verPedidosConta.place(x=335, y=400)
        button_verPedidosConta.config(width=20,height=5, fg="black")
        button_stock = tk.Button(self, text="Alerta Stock",command=lambda: controller.show_frame(Stock_Fornecedores))
        button_stock.place(x=490, y=400)
        button_stock.config(width=20,height=5, fg="black")
        button_clientes = tk.Button(self, text="Clientes",command=lambda: controller.show_frame(Consultar_Clientes))
        button_clientes.place(x=25, y=500)
        button_clientes.config(width=20,height=5, fg="black")

        self.label_xml = tk.Label(self, text="", font=LARGE_FONT)
        self.label_xml.place(x=245, y=655)
        self.label_xml.config(fg="black")          
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Inicio))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def gerar_xml(self):    
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT gravarXML("+str(restaurante)+")")
        resultado = cur.fetchone()
        r = str(resultado).replace("('", "")
        info = str(r).replace("',)", "")
        cur.close()
        conn.close() 
        arquivo = open('BackupDadosR&R.xml','w')
        arquivo.write(str(info))
        arquivo.close()
        self.label_xml.config(text="XML gravado com sucesso!")
        
class Consultar_Pratos(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_titulo = tk.Label(self, text="Consultar pratos", font=("Helvetica", 20))
        label_titulo.place(x=250, y=100)
        v = controller.ver_pratos()        #Ver pratos existentes
        label_prato = tk.Label(self, text="Pratos existentes:", font=LARGE_FONT)
        label_prato.place(x=150, y=300)
        prato = Combobox(self, values=v)
        prato.place(x=350, y = 300)
        button_detalhes = tk.Button(self, text="Ver detalhes", command=lambda: controller.show_detalhes_prato(prato.get()))
        button_detalhes.place(x=260, y=550)
        button_detalhes.config(width=25,height=2, background="#87E193", fg="black")
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=250, y=400)
        self.label_ERRO.config(fg="red")
        if admin == 1:
            button_inserir = tk.Button(self, text="Criar Prato", command=lambda: controller.show_frame(Inserir_Prato))
            button_inserir.place(x=260, y=600)
            button_inserir.config(width=25,height=2, background="#FFFFFA", fg="black")
            button_remover = tk.Button(self, text="Remover Prato", command=lambda: self.remover_prato(prato.get(), controller))
            button_remover.place(x=260, y=650)
            button_remover.config(width=25,height=2, background="#FFFFFA", fg="black")
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def remover_prato(self, p, controller):
        if p != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL remover_prato('" + p + "')")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar o prato\na eliminar!")
        return False

class Consultar_Ementa(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        labelEmenta = tk.Label(self, text="Ementa", font=("Helvetica", 20))
        labelEmenta.place(x=60, y=50)
        colunas = ('ID', 'Dia semanal', 'Prato', 'Preço')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=25, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=200)  
        vvv = self.ver_ementa()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=200, y=500)
        self.label_ERRO.config(fg="red")
        self.prato = ''
        self.lista.bind('<<TreeviewSelect>>', self.selectItem)
        if admin == 1:
            button_inserir = tk.Button(self, text="Inserir prato na ementa >", command=lambda: controller.show_frame(Inserir_Prato_Ementa))     
            button_inserir.place(x=450, y=50)
            button_inserir.config(width=25,height=2, background="white", fg="black")
            button_removerPrato = tk.Button(self, text="Remover prato da ementa", command=lambda: self.remover_prato(controller, self.prato))     
            button_removerPrato.place(x=260, y=600)
            button_removerPrato.config(width=25,height=2, background="#c4cbd5", fg="black")
            button_reset = tk.Button(self, text="Limpar ementa", command=lambda: self.limpar_ementa(controller))
            button_reset.place(x=260, y=650)
            button_reset.config(width=25,height=2, background="#c4cbd5", fg="black")
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
            button_voltar.place(x=25, y=650)
            button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        else:
            button_voltarfunc = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
            button_voltarfunc.place(x=25, y=650)
            button_voltarfunc.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def limpar_ementa(self, controller):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("CALL limpar_ementa(" + str(restaurante) + ")")
        cur.close()
        conn.close() 
        controller.show_frame(Ementas)

    def remover_prato(self, controller, id_e):
        if id_e != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL remover_prato_ementa(" + str(id_e) + ")")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar um prato para remover!")
        return False

    def selectItem(self, event):
        for item in self.lista.selection():
            item_text = self.lista.item(item, 'values')
            vvv = []
            x = 0
            for i in item_text: 
                if (i == '(' or i == "'") and x <= 2:
                    x = x + 1
                else:
                    vvv.append(i) 
                    break       
            vv = str(vvv).replace("['", "")
            p = str(vv).replace("']", "")
            self.prato = p

    def ver_ementa(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True    
        cur = conn.cursor()
        cur.execute("select * from ver_ementa(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close() 
        return v

class Consultar_HistoricoEmenta(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        labelEmenta = tk.Label(self, text="Histórico de Ementa", font=("Helvetica", 20))
        labelEmenta.place(x=230, y=80)
        colunas = ('Prato', 'Preço', 'Data', 'Dia Semanal')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=15, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=75, pady=200)  
        vvv = self.ver_hementa()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def ver_hementa(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True    
        cur = conn.cursor()
        cur.execute("select * from ver_historicoementa(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close() 
        return v

class Consultar_Alergias(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_pratosAlergias = tk.Label(self, text="Pratos com alergias", font=("Helvetica", 20))
        label_pratosAlergias.place(x=230, y=50)
        colunas = ('Prato', 'Produto', 'Alergia')
        lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            lista.heading(col, text=col, anchor='center')
            lista.column(col, width=15, anchor='center')
        lista.grid(row=1, column=0, columnspan=2)
        lista.pack(side=tk.TOP,fill=tk.X, pady=200, padx=20)
        vvv = self.ver_alergias()
        for data in vvv:
            lista.insert("", "end", values=data)

        if admin == 1: 
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
            button_associar = tk.Button(self, text="Associar alergia\na produto", command=lambda: controller.show_frame(Associar_Alergia_Produto))
            button_associar.place(x=260, y=650)
            button_associar.config(width=25,height=2, background="white", fg="black")
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def ver_alergias(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT * FROM ver_pratos_alergias()')
        vvv = cur.fetchall()     
        cur.close()
        conn.close() 
        return vvv

class Ver_Produtos(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label = tk.Label(self, text="Consultar produtos", font=("Helvetica", 20))
        label.place(x=230, y=60)
        colunas = ('Nome', 'Preço', 'IVA', 'Stock', 'Zona de confeção')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=15, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=150)        
        vvv = self.consultar_produtos()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=175, y=410)
        self.label_ERRO.config(fg="red")
        self.prod = ''
        self.lista.bind('<<TreeviewSelect>>', self.selectItem)

        if admin == 1:
            label_qnt = tk.Label(self, text="Quantidade:", font=LARGE_FONT)
            label_qnt.place(x=50, y= 500)
            qnt = tk.Entry(self, font=30)
            qnt.place(relwidth=0.30, rely=0.01, relheight=0.04, y=495, x=170)
            button_inserir = tk.Button(self, text="Criar novo", command=lambda: controller.show_frame(Inserir_Produtos))
            button_inserir.place(x=200, y=600)
            button_inserir.config(width=15,height=2, background="#87E193", fg="black")
            button_remover = tk.Button(self, text="Remover", command=lambda: self.remover_produto(self.prod, controller))
            button_remover.place(x=400, y=600)
            button_remover.config(width=15,height=2, background="#FFFFFA", fg="black")
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
            button_adicionar = tk.Button(self, text="Adicionar produtos",command=lambda: self.add_prod(self.prod, qnt.get(), controller))
            button_adicionar.place(x=420, y=495)
            button_adicionar.config(width=25,height=2, background="white", fg="black")
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas_func))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def selectItem(self, event):
        for item in self.lista.selection():
            item_text = self.lista.item(item, 'values')
            vvv = []
            x = 0
            for i in item_text: 
                if (i == '(' or i == "'") and x <= 2:
                    x = x + 1
                else:
                    vvv.append(i) 
                    break       
            vv = str(vvv).replace("['", "")
            p = str(vv).replace("']", "")
            self.prod = p

    def remover_produto(self, p, controller):
        if p != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL remover_produto('" + p + "')")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar um produto para remover!")
        return False

    def add_prod(self, p, quantidade, controller):
        if p != '' and controller.verifica_Numeros(quantidade):
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL adicionar_produtos('" + p + "'," + str(quantidade) + ")")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar um produto e quantidade a adicionar!")
        return False
    
    def consultar_produtos(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute('SELECT * FROM ver_produtos()')
        valor = cur.fetchall()
        cur.close()
        conn.close() 
        return valor

class Consultar_RegistoContas(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_pedidos = tk.Label(self, text="Pedidos de criação\nde contas", font=("Helvetica", 20))
        label_pedidos.place(x=220, y=50)
        colunas = ('ID', 'Data', 'Administrador', 'Username', 'Password')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=15, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=200)  
        vvv = self.ver_pedidos_registo()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=170, y=450)
        self.label_ERRO.config(fg="red")
        self.conta = ''
        self.lista.bind('<<TreeviewSelect>>', self.selectItem)

        button_confirmar = tk.Button(self, text="Confirmar conta", command=lambda: self.aceitar_criacao(controller, self.conta))     
        button_confirmar.place(x=260, y=600)
        button_confirmar.config(width=25,height=2, background="#c4cbd5", fg="black")
        button_rejeitar = tk.Button(self, text="Rejeitar pedido", command=lambda: self.remover_pedido_conta(controller, self.conta))
        button_rejeitar.place(x=260, y=650)
        button_rejeitar.config(width=25,height=2, background="#c4cbd5", fg="black")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def aceitar_criacao(self, controller, conta):
        if conta != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL confirmar_criacao_conta(" + str(conta) + ")")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar uma conta para confirmar!")
        return False

    def remover_pedido_conta(self, controller, conta):
        if conta != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True
            cur = conn.cursor()
            cur.execute("CALL remover_pedido_conta(" + str(conta) + ")")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="Deve selecionar uma conta para rejeitar!")
        return False

    def selectItem(self, event):
        for item in self.lista.selection():
            item_text = self.lista.item(item, 'values')
            vvv = []
            x = 0
            for i in item_text: 
                if (i == '(' or i == "'") and x <= 2:
                    x = x + 1
                else:
                    vvv.append(i) 
                    break       
            vv = str(vvv).replace("['", "")
            p = str(vv).replace("']", "")
            self.conta = p

    def ver_pedidos_registo(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True    
        cur = conn.cursor()
        cur.execute("select * from consultar_pedidos_registo(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close() 
        return v

class CriarConta(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        label_titulo = tk.Label(self, text="Criação de conta", font=("Helvetica", 20))
        label_titulo.place(x=240, y=110)

        label_user = tk.Label(self, text="Utilizador:", font=LARGE_FONT)
        label_user.place(x=150, y=250)
        user = tk.Entry(self, font=LARGE_FONT)
        user.place(relwidth=0.40, rely=0.01, relheight=0.05, y=240, x=265)
        user.focus_set()
        label_pass = tk.Label(self, text="Password:", font=LARGE_FONT)
        label_pass.place(x=150, y=330)
        password = tk.Entry(self, font=LARGE_FONT, show="*")
        password.place(relwidth=0.40, rely=0.01, relheight=0.05, y=320, x=265)
        password.focus_set()
        label_confirmar = tk.Label(self, text="Confirmar password:", font=LARGE_FONT)
        label_confirmar.place(x=65, y=410)
        confirmar_password = tk.Entry(self, font=LARGE_FONT, show="*")
        confirmar_password.place(relwidth=0.40, rely=0.01, relheight=0.05, y=400, x=265)
        confirmar_password.focus_set()
        label_funcao = tk.Label(self, text="Função:", font=LARGE_FONT)   #dia da semana
        label_funcao.pack(pady=30,padx=2)
        label_funcao.place(x=80, y=490)
        combo_funcao=Combobox(self, values=['Administrador', 'Funcionário'])
        combo_funcao.place(x=165, y = 490)
        label_rest = tk.Label(self, text="Restaurante:", font=LARGE_FONT)   #dia da semana
        label_rest.pack(pady=30,padx=2)
        label_rest.place(x=340, y=490)
        combo_rest=Combobox(self, values=['Titanic', 'Ti João', 'A caverna', 'Tons e Sabores'])
        combo_rest.place(x=455, y = 490)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=185, y=570)
        self.label_ERRO.config(fg="red")

        button_criar = tk.Button(self, text="Criar conta",command=lambda: self.criar_conta(user.get(), password.get(), confirmar_password.get(), combo_funcao.get(), combo_rest.get(), controller))
        button_criar.place(x=260, y=650)
        button_criar.config(width=25,height=2, background="#BDB76B", fg="black")
        if restaurante != 0 :
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        else:
            button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Inicio))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def criar_conta(self, user, password, conf_password, funcao, r, controller):
        rest = 0
        if user != '':
            if password != '':
                if funcao != '':
                    if r != '':
                        if r == 'Titanic':
                            rest = 1
                        elif r == 'Ti João':
                            rest = 2
                        elif r == 'A caverna':
                            rest = 3
                        else:
                            rest = 4
                        if password != conf_password:
                            self.label_ERRO.config(text="Já existe uma conta com esse nome de utilizador!")
                            return False
                        else:
                            enc_pass = hashlib.md5(password.encode()).hexdigest()
                            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                            conn.autocommit = True
                            cur = conn.cursor()
                            cur.execute("SELECT criar_conta('" + user + "','" + enc_pass + "','" + funcao + "'," + str(rest) + ")")
                            cur.close()
                            conn.close() 
                            controller.show_frame(Inicio)
                            return True
        else:
            self.label_ERRO.config(text="É necessário preencher todos os campos!")
            return False   
        
class Stock_Fornecedores(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        label_stock = tk.Label(self, text="Alerta de stock", font=("Helvetica", 20))
        label_stock.place(x=230, y=50)
        colunas = ('Produto', 'Quantidade', 'Stock Min.', 'Data', 'Fornecedor', 'Contacto')
        lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            lista.heading(col, text=col, anchor='center')
            lista.column(col, width=15, anchor='center')
        lista.grid(row=1, column=0, columnspan=2)
        lista.pack(side=tk.TOP,fill=tk.X, pady=200, padx=20)
        v = self.ver_alerta_stock()
        for data in v:
            lista.insert("", "end", values=data)

        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def ver_alerta_stock(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute("SELECT * FROM consultar_alertastock("+ str(restaurante) +")")
        v = cur.fetchall()     
        cur.close()
        conn.close() 
        return v

class Consultar_Clientes(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.pagina(parent, controller)

    def pagina(self, parent, controller):
        labelEmenta = tk.Label(self, text="Contas dos clientes", font=("Helvetica", 20))
        labelEmenta.place(x=60, y=50)
        colunas = ('Nº Cliente', 'Nome', 'NIF', 'Descrição')
        self.lista = ttk.Treeview(self, columns=colunas, show='headings')
        # set column headings
        for col in colunas:
            self.lista.heading(col, text=col, anchor='center')
            self.lista.column(col, width=25, anchor='center')
        self.lista.grid(row=1, column=0, columnspan=2, ipadx=250, padx=50, pady=100)  
        vvv = self.ver_clientes()
        for data in vvv:
            self.lista.insert("", "end", values=data)
        self.label_ERRO = tk.Label(self, text="", font=LARGE_FONT)
        self.label_ERRO.place(x=130, y=550)
        self.label_ERRO.config(fg="red")
        self.cliente = ''
        self.lista.bind('<<TreeviewSelect>>', self.selectItem)
        label_nif = tk.Label(self, text="NIF:", font=LARGE_FONT)
        label_nif.place(x=50, y= 350)
        nif = tk.Entry(self, font=30)
        nif.place(relwidth=0.30, rely=0.01, relheight=0.04, y=345, x=110)
        label_obs = tk.Label(self, text="Obs:", font=LARGE_FONT)
        label_obs.place(x=50, y= 400)
        obs = tk.Entry(self, font=30)
        obs.place(relwidth=0.30, rely=0.01, relheight=0.04, y=395, x=110)
        label_nome = tk.Label(self, text="Nome:", font=LARGE_FONT)
        label_nome.place(x=50, y= 450)
        nome = tk.Entry(self, font=30)
        nome.place(relwidth=0.30, rely=0.01, relheight=0.04, y=445, x=110)

        button_atualizarNome = tk.Button(self, text="Atualizar nome", command=lambda: self.atualizar_nome(self.cliente, nome.get(), controller))     
        button_atualizarNome.place(x=400, y=445)
        button_atualizarNome.config(width=25,height=2, background="#c4cbd5", fg="black")
        button_atualizarNIF = tk.Button(self, text="Atualizar NIF", command=lambda: self.atualizar_nif(self.cliente, nif.get(), controller))     
        button_atualizarNIF.place(x=400, y=345)
        button_atualizarNIF.config(width=25,height=2, background="#c4cbd5", fg="black")
        button_atualizarObs = tk.Button(self, text="Atualizar observações", command=lambda: self.atualizar_obs(self.cliente, obs.get(), controller))
        button_atualizarObs.place(x=400, y=395)
        button_atualizarObs.config(width=25,height=2, background="#c4cbd5", fg="black")
        button_voltar = tk.Button(self, text="Voltar", command=lambda: controller.show_frame(Ementas))
        button_voltar.place(x=25, y=650)
        button_voltar.config(width=25,height=2, background="#FF7F50", fg="black")
        button_sair = tk.Button(self, text="Sair", command=lambda: controller.endApp())
        button_sair.place(x=500, y=650)
        button_sair.config(width=25,height=2, background="#BC0022", fg="white")

    def selectItem(self, event):
        for item in self.lista.selection():
            item_text = self.lista.item(item, 'values')
            vvv = []
            x = 0
            for i in item_text: 
                if (i == '(' or i == "'") and x <= 2:
                    x = x + 1
                else:
                    vvv.append(i) 
                    break       
            vv = str(vvv).replace("['", "")
            p = str(vv).replace("']", "")
            self.cliente = p

    def ver_clientes(self):
        conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
        conn.autocommit = True    
        cur = conn.cursor()
        cur.execute("select * from consultar_clientes(" + str(restaurante) + ")")
        v = cur.fetchall()
        cur.close()
        conn.close() 
        return v

    def atualizar_nif(self, cliente, nif, controller):
        if cliente != '' and nif != '':
            if controller.verifica_Numeros(nif):
                conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                conn.autocommit = True    
                cur = conn.cursor()
                cur.execute("CALL atualizarnif_cliente(" + cliente + "," + nif + ")")
                cur.close()
                conn.close() 
                controller.show_frame(Ementas)
                return True
        self.label_ERRO.config(text="É necessário preencher todos os campos devidamente, \nassim como selecionar o cliente!")
        return False 
    
    def atualizar_nome(self, cliente, nome, controller):
        if cliente != '' and nome != '':
            if not controller.verifica_Numeros(nome):
                conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
                conn.autocommit = True    
                cur = conn.cursor()
                cur.execute("CALL atualizarnome_cliente(" + cliente + ",'" + nome + "')")
                cur.close()
                conn.close() 
                controller.show_frame(Ementas)
                return True
        self.label_ERRO.config(text="É necessário preencher todos os campos devidamente, \nassim como selecionar o cliente!")
        return False

    def atualizar_obs(self, cliente, obs, controller):
        if cliente != '' and obs != '':
            conn = psycopg2.connect(host = "localhost", database = "RestaurantManagement", user = "postgres", password = "8DE2DF6A4D")
            conn.autocommit = True    
            cur = conn.cursor()
            cur.execute("CALL atualizarnome_cliente(" + cliente + ",'" + obs + "')")
            cur.close()
            conn.close() 
            controller.show_frame(Ementas)
            return True
        self.label_ERRO.config(text="É necessário preencher todos os campos devidamente, \nassim como selecionar o cliente!")
        return False

app = ecra_entrada()
app.mainloop()