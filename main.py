import os
import sys

class RobotTestRunner:
    def __init__(self):
        self.current_dir = os.path.dirname(os.path.abspath(__file__))
        self.logs_dir = os.path.join(self.current_dir, 'logs')
        self.features_dir = os.path.join(self.current_dir, 'test', 'api')
        
        # Lista de testes disponíveis
        self.available_tests = {
            '1': '1device/1GET_devices.robot',
            '2': '1device/2POST_devices.robot',
            '3': '2user/1GET_user.robot',
            '4': '4client/1GET_client.robot'
        }

    def run_robot_test(self, feature_name):
        """Executa um teste específico do Robot Framework"""
        print(f"\n{'='*20} Executando {feature_name} {'='*20}")
        
        feature_path = os.path.join(self.features_dir, feature_name)
        log_dir = os.path.join(self.logs_dir, feature_name.replace('.robot', ''))
        
        # Comando robot direto
        command = f"robot -d {log_dir} {feature_path}"
        
        try:
            # Executa o comando diretamente
            os.system(command)
            return True
        except Exception as e:
            print(f"Erro ao executar {feature_name}: {str(e)}")
            return False

    def run_all_tests(self):
        """Executa todos os testes disponíveis"""
        print("\n====== Iniciando Execução de Todos os Testes ======")
        
        results = []
        for test_id, feature_name in self.available_tests.items():
            success = self.run_robot_test(feature_name)
            results.append((feature_name, success))
        
        print("\n====== Resumo da Execução ======")
        for feature_name, success in results:
            status = "PASS" if success else "FAIL"
            print(f"{feature_name}: {status}")

    def show_menu(self):
        """Exibe menu de opções"""
        print("\n====== Menu de Testes ======")
        print("1. Executar GET Devices")
        print("2. Executar POST Devices")
        print("3. Executar GET Users")
        print("4. Executar GET Clients")
        print("5. Executar Todos os Testes")
        print("0. Sair")
        
        option = input("\nEscolha uma opção: ")
        
        if option == '5':
            self.run_all_tests()
        elif option == '0':
            sys.exit(0)
        elif option in self.available_tests:
            self.run_robot_test(self.available_tests[option])
        else:
            print("Opção inválida!")

    def run(self):
        """Executa o runner"""
        while True:
            try:
                self.show_menu()
            except KeyboardInterrupt:
                print("\nExecução interrompida pelo usuário")
                sys.exit(0)

if __name__ == "__main__":
    runner = RobotTestRunner()
    runner.run() 