package com.nextcalendar.dto.address;

import com.nextcalendar.entity.AddressEmbeddable;

public record AddressResponseDTO(
        String cep,
        String street,
        String number,
        String complement,
        String neighborhood,
        String city,
        String state
) {
    public AddressResponseDTO(AddressEmbeddable address) {
        this(
                address != null ? address.getCep() : null,
                address != null ? address.getStreet() : null,
                address != null ? address.getNumber() : null,
                address != null ? address.getComplement() : null,
                address != null ? address.getNeighborhood() : null,
                address != null ? address.getCity() : null,
                address != null ? address.getState() : null
        );
    }
}
