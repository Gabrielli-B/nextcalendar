package com.nextcalendar.controller.openapi;

import com.nextcalendar.dto.*;
import com.nextcalendar.dto.establishment.EstablishmentCreateDTO;
import com.nextcalendar.dto.establishment.EstablishmentResponseDTO;
import com.nextcalendar.dto.establishment.EstablishmentUpdateDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

import java.util.UUID;

@Tag(name = "Estabelecimentos", description = "Endpoints para gerenciamento do estabelecimento e utilitários")
public interface EstablishmentApi {

    @Operation(summary = "Cadastrar estabelecimento", description = "Cria o estabelecimento com trial de 30 dias e perfil GESTOR automaticamente.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Estabelecimento criado com sucesso"),
            @ApiResponse(responseCode = "400", description = "CNPJ ou e-mail já cadastrado no sistema"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário ou CEP inválidos")
    })
    EstablishmentResponseDTO create(EstablishmentCreateDTO dto);

    @Operation(summary = "Buscar estabelecimento por ID", description = "Retorna os dados do estabelecimento para exibição na tela Empresa.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estabelecimento encontrado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado")
    })
    EstablishmentResponseDTO findById(UUID id);

    @Operation(summary = "Atualizar estabelecimento", description = "Atualiza parcialmente os dados do estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estabelecimento atualizado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    EstablishmentResponseDTO update(UUID id, EstablishmentUpdateDTO dto);

    @Operation(summary = "Inativar estabelecimento", description = "Realiza a inativação (soft delete) do estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Estabelecimento inativado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado")
    })
    void delete(UUID id);

    @Operation(summary = "Buscar estabelecimento por proprietário", description = "Busca o estabelecimento vinculado ao usuário autenticado.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Estabelecimento encontrado"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado para este proprietário")
    })
    EstablishmentResponseDTO findByOwner(UUID ownerId);

    @Operation(summary = "Aceitar termos de uso", description = "Registra o aceite dos termos de uso pelo estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Termos aceitos com sucesso"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado")
    })
    EstablishmentResponseDTO acceptTerms(UUID id);

    @Operation(summary = "Consultar status do trial", description = "Retorna dias restantes, aviso prévio e status de expiração do trial.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Status do trial retornado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado")
    })
    TrialStatusDTO getTrialStatus(UUID id);

    @Operation(summary = "Consultar CEP", description = "Consulta a API do ViaCEP para preenchimento automático do endereço.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Endereço localizado com sucesso"),
            @ApiResponse(responseCode = "422", description = "Formato de CEP inválido"),
            @ApiResponse(responseCode = "503", description = "Serviço ViaCEP indisponível")
    })
    ViaCepResponseDTO consultarCep(String cep);
}