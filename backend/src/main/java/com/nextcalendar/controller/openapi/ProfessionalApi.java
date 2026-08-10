package com.nextcalendar.controller.openapi;

import com.nextcalendar.dto.professional.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

@Tag(name = "Profissionais", description = "Endpoints para gerenciamento de profissionais do estabelecimento")
public interface ProfessionalApi {

    @Operation(summary = "Cadastrar profissional", description = "Cadastra um novo profissional vinculado a um estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Profissional cadastrado com sucesso"),
            @ApiResponse(responseCode = "400", description = "E-mail ou CPF já cadastrado no sistema"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ProfessionalProfileResponseDTO createProfessional(UUID establishmentId, ProfessionalCreateDTO dto);

    @Operation(summary = "Atualizar profissional (Admin)", description = "Atualiza todas as informações do profissional, incluindo comissão e status.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profissional atualizado com sucesso"),
            @ApiResponse(responseCode = "400", description = "E-mail ou CPF em uso por outro profissional"),
            @ApiResponse(responseCode = "404", description = "Profissional não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ProfessionalDetailsResponseDTO updateProfessionalByAdmin(UUID id, ProfessionalAdminUpdateDTO dto);

    @Operation(summary = "Atualizar próprio perfil", description = "Permite que o profissional atualize apenas seus dados cadastrais básicos.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Perfil atualizado com sucesso"),
            @ApiResponse(responseCode = "400", description = "E-mail em uso por outro profissional"),
            @ApiResponse(responseCode = "404", description = "Profissional não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ProfessionalProfileResponseDTO updateProfessionalBySelf(UUID id, ProfessionalSelfUpdateDTO dto);

    @Operation(summary = "Buscar profissional por ID", description = "Retorna os detalhes completos de um profissional específico do estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Profissional encontrado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Profissional ou estabelecimento não encontrado")
    })
    ProfessionalDetailsResponseDTO findProfessionalById(UUID establishmentId, UUID id);

    @Operation(summary = "Listar todos os profissionais", description = "Retorna uma lista paginada com todos os profissionais do estabelecimento.")
    @ApiResponse(responseCode = "200", description = "Lista retornada com sucesso")
    Page<ProfessionalMinResponseDTO> findByEstablishment(UUID establishmentId, Pageable pageable);

    @Operation(summary = "Listar profissionais ativos", description = "Retorna uma lista paginada apenas com os profissionais ativos do estabelecimento.")
    @ApiResponse(responseCode = "200", description = "Lista retornada com sucesso")
    Page<ProfessionalMinResponseDTO> findActiveByEstablishment(UUID establishmentId, Pageable pageable);

    @Operation(summary = "Buscar profissionais por nome", description = "Realiza a busca paginada de profissionais do estabelecimento filtrando pelo nome.")
    @ApiResponse(responseCode = "200", description = "Busca realizada com sucesso")
    Page<ProfessionalMinResponseDTO> findByNameAndEstablishment(String name, UUID establishmentId, Pageable pageable);

    @Operation(summary = "Inativar profissional", description = "Realiza o soft delete (inativação) do cadastro do profissional.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Profissional inativado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Profissional não encontrado")
    })
    void deleteProfessional(UUID id);
}