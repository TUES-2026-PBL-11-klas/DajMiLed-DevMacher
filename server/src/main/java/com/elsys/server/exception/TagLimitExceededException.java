package com.elsys.server.exception;

import com.elsys.server.entity.TagCategory;

public class TagLimitExceededException extends RuntimeException {
    public TagLimitExceededException(TagCategory category) {
        super("Maximum of 20 tags reached for category " + category);
    }
}
