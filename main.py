import os
import string
# import FunYtDown
import FunOp1
import yaml

#* Mensajes del sistema
msg_TODO = "Estamos en ello..."
msg_init = ('\033[31m'+"S"+'\033[39m'+"olucion de "+'\033[31m'+"E"+'\033[39m'+"ntornos de "+'\033[31m'+"T"+'\033[39m'+"rabajo "+'\033[31m'+"R"+'\033[39m'+"apid"+'\033[31m'+"OS"+"\n_.SETROS._\n\n"+'\033[39m')
msg_OpInit = "1.- Ver instalaciones dispobibles\n" \
             "2.- Instalar y configurar Todo el Entorno\n" \
             "3.- Instalar y configurar herramientas por bloques\n"\
             "4.- Monitores de herramientas\n"\
             "0.- Salir"\
             "\n\n"
msg_noCar = "Ingresa una opcion valida porfavor"

#* Variables del sistema
caracteres = list(string.ascii_letters + string.punctuation)
msgSystem = "~[System//msg]~::"
msgInp = "~[user//op]~:: "
manErrOp = "Ultima respuesta: "
caris0 = 0

def main():
    global caris0
    OpInitSystem = ""
    
    while True:
        os.system("clear")
        print(msg_init)
        print(msg_OpInit)

        if caris0 >= 1:
            print(msgSystem + msg_noCar + manErrOp, OpInitSystem)
        
        OpInitSystem = input(msgInp).strip()  #? Elimina espacios en blanco
        
        # Verificar si hay caracteres no numéricos
        caris0 = 0
        for car in caracteres:
            if car in OpInitSystem:
                caris0 = 1
                break
        
        #? Si no hay caracteres especiales, convertir a entero
        if caris0 == 0:
            try:
                OpInitSystem_int = int(OpInitSystem)  #* Convertimos a entero
            except ValueError:
                caris0 = 1  #* Si falla la conversión (ej: entrada vacía)
                continue
            
            if OpInitSystem_int == 0:
                quit()
            elif OpInitSystem_int == 1:
                os.system("clear")
                print(msgSystem + msg_TODO)
                FunOp1.fun_op1()
            else:
                continue
        
main()