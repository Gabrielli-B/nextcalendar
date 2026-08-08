package com.nextcalendar.controller.openapi;

import com.nextcalendar.dto.services.ServiceCreateDTO;
import com.nextcalendar.dto.services.ServiceMinResponseDTO;
import com.nextcalendar.dto.services.ServiceUpdateDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

@Tag(name = "Serviços", description = "Endpoints para gerenciamento de serviços do estabelecimento")
public interface ServiceApi {

    @Operation(summary = "Cadastrar serviço", description = "Cadastra um novo serviço vinculado a um estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Serviço cadastrado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Regra de negócio violada"),
            @ApiResponse(responseCode = "404", description = "Estabelecimento não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ServiceMinResponseDTO createService(ServiceCreateDTO serviceDTO, UUID establishmentId);

    @Operation(summary = "Atualizar serviço", description = "Atualiza os dados de um serviço existente no estabelecimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Serviço atualizado com sucesso"),
            @ApiResponse(responseCode = "404", description = "Serviço ou estabelecimento não encontrado"),
            @ApiResponse(responseCode = "422", description = "Dados do formulário inválidos")
    })
    ServiceMinResponseDTO updateService(UUID establishmentId, UUID idService, ServiceUpdateDTO serviceDTO);

    @Operation(summary = "Buscar serviços por nome", description = "Realiza a busca paginada de serviços filtrando pelo nome.")
    @ApiResponse(responseCode = "200", description = "Busca realizada com sucesso")
    Page<ServiceMinResponseDTO> findServicesByName(String name, UUID establishmentId, Pageable pageable);

    @Operation(summary = "Listar todos os serviços", description = "Retorna uma lista paginada com todos os serviços do estabelecimento.")
    @ApiResponse(responseCode = "200", description = "Lista retornada com sucesso")
    Page<ServiceMinResponseDTO> findAllServices(UUID establishmentId, Pageable pageable);

    @Operation(summary = "Inativar/Excluir serviço", description = "Remove ou inativa um serviço cadastrado.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Serviço removido com sucesso"),
            @ApiResponse(responseCode = "404", description = "Serviço não encontrado")
    })
    void deleteService(UUID id);
}