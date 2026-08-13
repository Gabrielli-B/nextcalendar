package com.nextcalendar.service;

import com.nextcalendar.dto.client.*;
import com.nextcalendar.dto.login_register.RegisterRequestDTO;
import com.nextcalendar.entity.ClientEntity;
import com.nextcalendar.entity.UserEntity;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.EntityNotFoundException;
import com.nextcalendar.mapper.ClientMapper;
import com.nextcalendar.repository.ClientRepository;

import org.springframework.stereotype.Service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class ClientService {
    private final ClientRepository clientRepository;

    private final ClientMapper clientMapper;

    public ClientService(ClientRepository clientRepository, ClientMapper clientMapper) {
        this.clientRepository=clientRepository;
        this.clientMapper=clientMapper;
    }

    @Transactional
    public ClientEntity createClientFromRegistration(
            UserEntity user,
            RegisterRequestDTO dto
    ) {

        if (clientRepository.existsByEmail(user.getEmail())) {
            throw new BusinessException(
                    "O e-mail " + user.getEmail()
                            + " já está cadastrado como cliente."
            );
        }

        ClientEntity client = new ClientEntity();

        client.setUserId(user.getId());
        client.setName(user.getName());
        client.setPhone(dto.phone());
        client.setEmail(user.getEmail());
        client.setDateOfBirth(dto.dateOfBirth());
        client.setPhotoUrl(dto.photoUrl());
        client.setNotes(dto.notes());
        client.setActive(true);

        return clientRepository.save(client);
    }

    public ClientProfileResponseDTO createClient(ClientCreateDTO clientDto){

        if (clientRepository.existsByEmail(clientDto.email())){
            throw new BusinessException("o E-mail " + clientDto.email() + " já está cadastrado no sistema.");
        }
        ClientEntity client = clientMapper.toEntity(clientDto);

        ClientEntity savedClient = clientRepository.save(client);

        return new ClientProfileResponseDTO(savedClient);
    }


    public ClientProfileResponseDTO updateClient(UUID id, ClientUpdateDTO clientDto){

        ClientEntity client = clientRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Cliente",id));

        if(clientDto.email() != null && !clientDto.email().isBlank() && !clientDto.email().equals(client.getEmail())){
            if (clientRepository.existsByEmailAndIdNot(clientDto.email(), id)) {
                throw new BusinessException("O e-mail '" + clientDto.email() + "' já está sendo usado por outro cliente.");
            }
        }

        clientMapper.updateEntity(client,clientDto);

        ClientEntity savedClient = clientRepository.save(client);

        return new ClientProfileResponseDTO(savedClient);
    }

    public ClientDetailsResponseDTO findClientById(UUID id){
        ClientEntity client = clientRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Cliente",id));
        return new ClientDetailsResponseDTO(client);
    }


    public Page<ClientMinResponseDTO> findClientsByName(String name, Pageable pageable){
       return clientRepository.findByNameContainingIgnoreCaseAndActiveTrue(name,pageable)
                .map(ClientMinResponseDTO::new);

    }

    public void deleteClient(UUID id){
        ClientEntity client = clientRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Cliente",id));
        client.setActive(false);
        clientRepository.save(client);
    }
}
