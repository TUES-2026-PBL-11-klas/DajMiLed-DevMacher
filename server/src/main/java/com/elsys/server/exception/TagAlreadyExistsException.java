package com.elsys.server.exception;

import com.elsys.server.entity.TagCategory;

public class TagAlreadyExistsException extends RuntimeException {
    public TagAlreadyExistsException(String name, TagCategory category) {
        super("Tag '" + name + "' already exists in category " + category);
    }
}
