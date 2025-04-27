package com.example.mocktest.model;

import java.util.ArrayList;
import java.util.List;

public class Chapter {

    private String id;
    private String name;
    private List<MCQ> mcqs;

    // Default constructor
    public Chapter() {
        this.mcqs = new ArrayList<>();
    }

    // Constructor that takes a string - used for deserialization from String values
    public Chapter(String id, String name) {
        this.id = id;
        this.name = name;
        this.mcqs = new ArrayList<>();
    }
    
    // Add a single string constructor for direct deserialization from string
    public Chapter(String name) {
        this.name = name;
        this.id = name.replaceAll("\\s+", "_").toLowerCase();
        this.mcqs = new ArrayList<>();
    }

    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public List<MCQ> getMcqs() {
        return mcqs;
    }

    public void setMcqs(List<MCQ> mcqs) {
        this.mcqs = mcqs;
    }

    @Override
    public String toString() {
        return name;
    }
}
