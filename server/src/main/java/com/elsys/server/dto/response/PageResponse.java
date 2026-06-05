package com.elsys.server.dto.response;

import java.util.List;

public record PageResponse<T>(List<T> content, boolean last) {}
