NEXTCALENDAR
================================================================

NOME DO PROJETO
NextCalendar

IDENTIFICAÇÃO DO GRUPO
Grupo 3
NextCalendar — Sistema Integrado de Gestão e Agendamento

Dados Acadêmicos & Equipe
Instituição de Ensino Superior (IES):  Faculdade/Universidade Unisinos
<<<<<<< Updated upstream
Empresa Parceira / Cliente: Studio Vision, Gabriel e Bárbara
Integrantes do Grupo 3:
=======
Empresa Parceira / Cliente: Studio Vision, Gabriel e Barbara
Integrantes do Grupo:
>>>>>>> Stashed changes
  * Fabio Leandro de Oliveira
  * Livia Freire Pinto
  * Gabrielli Borba e Oliveira
  * Pedro Mathias Da Silva Marcolino
  * Roberto Medeiros de Lima

Tecnologias Utilizadas: Java 21 LTS, Spring Boot 3, Spring Security (JWT), Spring Data JPA, Hibernate, React Native, Expo Web (SDK 56), PostgreSQL 16, H2 Database e Docker.
Arquitetura do Monorepo

O repositório está estruturado em monorepo modular, separando responsabilidades:

nextcalendar/
├── backend/              # API REST principal em Spring Boot 3 / Java 21 LTS
│   ├── src/              # Controladores, Entidades JPA, Services e Mappers
│   ├── e2e/              # Suíte de testes automatizados ponta a ponta (HURL)
│   └── README.md         # Documentação técnica detalhada dos endpoints
├── frontend/             # Aplicação Web e Mobile do Gestor e Cliente (Expo / React Native)
├── AgenteBarbearia/      # Microserviço de IA (.NET 10 + OpenAI GPT-4o-mini + Whisper)
│   └── whatsapp-bridge/  # Ponte de integração WhatsApp (Node.js / Baileys)
├── docs/                 # Modelos de dados, protótipos e apresentação da banca
└── docker-compose.yml    # Orquestração do PostgreSQL (API) e MongoDB (Agente)

Protótipo Interativo (Figma): (https://www.figma.com/design/9PTnqWDmqBg1H6oLZfvjmZ/Next-calendar?node-id=203-797&t=ZfFPLf9qMO8Y8IPX-0)

ESCOPO DA SOLUÇÃO
O NextCalendar é uma solução multiplataforma (Android, iOS e Web) de
autoagendamento desenvolvida para o Studio Vision, um estabelecimento de
barbearia e salão de beleza. O sistema conecta o cliente final ao
estabelecimento para agendamento online de serviços, ao mesmo tempo em que
oferece uma área restrita para o profissional gerenciar seus atendimentos,
comandas e o histórico técnico dos clientes, e para o gestor administrar
equipe, serviços e agenda. A solução é construída em React
Native (frontend) e Spring Boot (backend).
<<<<<<< Updated upstream
=======

INTEGRANTES DO GRUPO
- Fábio Leandro Santos de Oliveira
- Gabrielli Borba de Oliveira
- Livia Freire Pinto
- Pedro Mathias Da Silva Marcolino
- Roberto Medeiros de Lima
>>>>>>> Stashed changes
