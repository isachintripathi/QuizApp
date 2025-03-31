package com.example.mocktest.model;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import java.util.List;

public class Topic {
    private String name;

    @JsonDeserialize(using = SubjectListDeserializer.class)  // Attach custom deserializer
    private List<Subject> subjects;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Subject> getSubjects() {
        return subjects;
    }

    public void setSubjects(List<Subject> subjects) {
        this.subjects = subjects;
    }
}
