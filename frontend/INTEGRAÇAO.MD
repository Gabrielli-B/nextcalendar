🔗 Diagnóstico de Integração — Frontend ↔ Backend
Visão Geral
O projeto já possui uma camada de serviços bem estruturada no frontend (src/services/) e os controllers REST correspondentes no backend. A integração está parcialmente implementada, com algumas telas já prontas e outras ainda usando mocks.

✅ JÁ INTEGRADO (pode usar agora, só precisa rodar o back)
1. Login — POST /api/v1/auth/login
Frontend	
login.tsx
 → 
authServices.ts
Backend	
AuthController.java
 → 
AuthService.java
Status	✅ Totalmente pronto
Como funciona	login.tsx chama signIn() do AuthContext, que usa authServices.login(), que faz POST /api/v1/auth/login. O JWT é salvo no SecureStore e injetado automaticamente em todas as requisições via interceptor no api.ts.
2. Registro de Cliente — POST /api/v1/auth/register
Frontend	
register.tsx
 → 
authServices.ts
Backend	
AuthController.java
Status	✅ Integrado, mas tem 1 bug
WARNING

Em 
register.tsx
linha 84-87
 existe um segundo botão <Button> duplicado que redireciona direto para /home sem chamar a API. Esse botão precisa ser removido.

3. Tela Empresa (UC03 + UC02 + UC06)
Frontend	
empresa.tsx
 → 
establishmentServices.ts
Backend	
EstablishmentController.java
Status	✅ Totalmente integrado
Endpoints usados	GET /establishments/owner/{ownerId}, PUT /establishments/{id}, GET /cep/{cep}
🔧 MOCKS — Precisa integrar com o back
4. Agendamentos do Cliente — bookingServices.ts
Frontend	
bookingServices.ts
 — retorna dados hardcoded
Backend	❌ Nenhum BookingController existe ainda
Status	🔴 Mock no front, endpoint não existe no back
O que falta	Criar BookingController.java + BookingService.java + endpoints GET /bookings/me e DELETE /bookings/{id}
5. Agenda do Gestor — agendaServices.ts
Frontend	
agendaServices.ts
 — 3 funções mock
Backend	❌ Nenhum AgendaController existe ainda
Status	🔴 Mock no front, endpoint não existe no back
O que falta	Criar endpoints: GET /agenda?date=YYYY-MM-DD, POST /appointments, PATCH /appointments/{id}/cancel, PATCH /slots/{id}/block
⚠️ EXISTE NO BACK, NÃO CONECTADO NO FRONT
6. Gestão de Serviços (CRUD) — ServiceController
Frontend	❌ Nenhum serviceServices.ts criado
Backend	
ServiceController.java
 — CRUD completo pronto
Status	🟡 Back pronto, front sem serviço de conexão
Endpoints disponíveis	GET /establishments/{id}/services, POST, PUT /{serviceId}, DELETE /{serviceId}
7. Gestão de Clientes (CRUD) — ClientController
Frontend	❌ Nenhum clientServices.ts criado
Backend	
ClientController.java
 — CRUD completo pronto
Status	🟡 Back pronto, front sem serviço de conexão
Endpoints disponíveis	GET /clients/search, GET /clients/{id}, POST /clients, PUT /clients/{id}, DELETE /clients/{id}
8. Registro de Empresa (Gestor) — register-empresa.tsx
Frontend	
register-empresa.tsx
 — usa registerEmpresa() do authServices
Backend	POST /api/v1/auth/register + POST /api/v1/establishments
Status	🟡 Parcialmente — o registro do usuário GESTOR pode funcionar, mas a criação do Establishment precisa ser verificada se está sendo chamada
🗺️ Mapa Resumido
Funcionalidade	Front	Back	Integrado?
Login	✅	✅	✅ Sim
Registro cliente	✅	✅	✅ Sim (bug menor)
Tela Empresa (ver/editar)	✅	✅	✅ Sim
Consulta CEP	✅	✅	✅ Sim
Agendamentos do cliente	🔴 Mock	❌	🔴 Não
Agenda do Gestor (slots)	🔴 Mock	❌	🔴 Não
CRUD de Serviços	❌	✅	🟡 Back pronto
CRUD de Clientes	❌	✅	🟡 Back pronto
Registro empresa (Gestor)	✅	✅	🟡 Verificar
🚀 Próximos Passos Recomendados
Remover o botão duplicado no register.tsx (linha 84-87)
Criar serviceServices.ts no front para conectar ao ServiceController já pronto
Criar clientServices.ts no front para conectar ao ClientController já pronto
Criar BookingController no back e substituir os mocks do bookingServices.ts
Criar AgendaController no back e substituir os mocks do agendaServices.ts
IMPORTANT

Para testar as integrações, o backend precisa estar rodando em localhost:8080. No emulador Android, o frontend aponta para 10.0.2.2:8080 automaticamente (configurado no api.ts).