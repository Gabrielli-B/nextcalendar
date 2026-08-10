package com.nextcalendar.service;

import com.nextcalendar.dto.client.*;
import com.nextcalendar.entity.ClientEntity;
import com.nextcalendar.entity.UserEntity;
import com.nextcalendar.entity.UserRole;
import com.nextcalendar.exception.BusinessException;
import com.nextcalendar.exception.EntityNotFoundException;
import com.nextcalendar.mapper.ClientMapper;
import com.nextcalendar.repository.ClientRepository;

import com.nextcalendar.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class ClientService {
    private final ClientRepository clientRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final ClientMapper clientMapper;

    public ClientService(ClientRepository clientRepository,
                         UserRepository userRepository,
                         PasswordEncoder passwordEncoder,
                         ClientMapper clientMapper) {

        this.clientRepository=clientRepository;
        this.userRepository=userRepository;
        this.passwordEncoder=passwordEncoder;
        this.clientMapper=clientMapper;
    }

    @Transactional
    public ClientProfileResponseDTO createClient(ClientCreateDTO clientDto){

        if (userRepository.existsByEmail(clientDto.email()) || clientRepository.existsByEmail(clientDto.email())) {
            throw new BusinessException("O e-mail " + clientDto.email() + " já está cadastrado no sistema.");
        }

        UserEntity user = new UserEntity();
        user.setName(clientDto.name());
        user.setEmail(clientDto.email());
        user.setPasswordHash(passwordEncoder.encode(clientDto.password()));
        user.setRole(UserRole.CUSTOMER);
        user.setActive(true);
        userRepository.save(user);

        ClientEntity client = clientMapper.toEntity(clientDto);
        ClientEntity savedClient = clientRepository.save(client);

        return new ClientProfileResponseDTO(savedClient);
    }


    @Transactional
    public ClientProfileResponseDTO updateClient(UUID id, ClientUpdateDTO clientDto){

        ClientEntity client = clientRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Cliente",id));

        if (clientDto.email() != null && !clientDto.email().isBlank() && !clientDto.email().equals(client.getEmail())) {
            if (userRepository.existsByEmail(clientDto.email()) || clientRepository.existsByEmailAndIdNot(clientDto.email(), id)) {
                throw new BusinessException("O e-mail '" + clientDto.email() + "' já está sendo usado por outro usuário.");
            }

            userRepository.findByEmail(client.getEmail()).ifPresent(user -> {
                user.setEmail(clientDto.email());
                userRepository.save(user);
            });
        }
        clientMapper.updateEntity(client,clientDto);

        ClientEntity savedClient = clientRepository.save(client);

        return new ClientProfileResponseDTO(savedClient);
    }

    @Transactional(readOnly = true)
    public ClientDetailsResponseDTO findClientById(UUID id){
        ClientEntity client = clientRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Cliente",id));
        return new ClientDetailsResponseDTO(client);
    }


    @Transactional(readOnly = true)
    public Page<ClientMinResponseDTO> findClientsByName(String name, Pageable pageable){
       return clientRepository.findByNameContainingIgnoreCaseAndActiveTrue(name,pageable)
                .map(ClientMinResponseDTO::new);

    }

    @Transactional
    public void deleteClient(UUID id){
        ClientEntity client = clientRepository.findById(id).orElseThrow(()->new EntityNotFoundException("Cliente",id));
        client.setActive(false);
        clientRepository.save(client);

        userRepository.findByEmail(client.getEmail()).ifPresent(user -> {
            user.setActive(false);
            userRepository.save(user);
        });
    }
}
