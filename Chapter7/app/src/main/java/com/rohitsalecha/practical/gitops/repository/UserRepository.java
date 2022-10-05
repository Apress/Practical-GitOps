package com.rohitsalecha.practical.gitops.repository;

import java.util.List;
import com.rohitsalecha.practical.gitops.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByName(String name);
}