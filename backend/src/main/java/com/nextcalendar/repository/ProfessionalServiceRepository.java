package com.nextcalendar.repository;

import com.nextcalendar.entity.ProfessionalServiceEntity;
import com.nextcalendar.entity.ProfessionalServiceId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ProfessionalServiceRepository extends JpaRepository<ProfessionalServiceEntity, ProfessionalServiceId> {

	List<ProfessionalServiceEntity> findById_ProfessionalId(UUID professionalId);

	List<ProfessionalServiceEntity> findByProfessional_Establishment_Id(UUID establishmentId);

	boolean existsById_ProfessionalIdAndIdServiceId(UUID professionalId, UUID serviceId);

	long countById_ProfessionalId(UUID professionalId);

	long countById_ServiceId(UUID serviceId);

	@Modifying
	@Query("delete from ProfessionalServiceEntity ps where ps.id.professionalId = :professionalId")
	void deleteAllByProfessionalId(@Param("professionalId") UUID professionalId);

}
