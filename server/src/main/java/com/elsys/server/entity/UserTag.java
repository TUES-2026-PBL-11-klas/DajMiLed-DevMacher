package com.elsys.server.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode
public class UserTag {

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false)
    private TagCategory category;

    @Column(name = "name", nullable = false, length = 50)
    private String name;
}
