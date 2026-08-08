package com.nextcalendar.controller.openapi;

import com.nextcalendar.dto.client.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

@Tag(name = "Clientes", description = "Endpoints para gerenciamento de clientes")
public interface ClientApi {

    @Operation(summary = "Cadastrar cliente", description = "Cadastra um novo cliente no sistema.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Cliente cadastrado com sucesso"),
            @ApiResponse(responseCode = "400", description = "E-mail já cadastrado no sistema"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ClientProfileResponseDTO createClient(ClientCreateDTO clientDto);

    @Operation(summary = "Buscar cliente por ID", description = "Retorna os detalhes completos de um cliente específico.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Cliente encontrado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Cliente não encontrado")
    })
    ClientDetailsResponseDTO findClientById(UUID id);

    @Operation(summary = "Buscar clientes por nome", description = "Realiza a busca paginada de clientes ativos filtrando pelo nome.")
    @ApiResponse(responseCode = "200", description = "Busca realizada com sucesso")
    Page<ClientMinResponseDTO> findClientsByName(String name, Pageable pageable);

    @Operation(summary = "Atualizar cliente", description = "Atualiza os dados cadastrais de um cliente existente.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Cliente atualizado com sucesso"),
            @ApiResponse(responseCode = "400", description = "E-mail em uso por outro cliente"),
            @ApiResponse(responseCode = "404", description = "Cliente não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ClientProfileResponseDTO updateClient(UUID id, ClientUpdateDTO dto);

    @Operation(summary = "Inativar cliente", description = "Realiza o soft delete (inativação) do cadastro do cliente.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Cliente inativado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Cliente não encontrado")
    })
    void deleteClient(UUID id);
}