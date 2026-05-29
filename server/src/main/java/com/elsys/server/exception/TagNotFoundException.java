package com.elsys.server.exception;

import com.elsys.server.entity.TagCategory;

public class TagNotFoundException extends RuntimeException {
    public TagNotFoundException(String name, TagCategory category) {
        super("Tag '" + name + "' not found in category " + category);
    }
}
