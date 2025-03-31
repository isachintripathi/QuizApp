package com.quiz.model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class User {
    private String name;
    private LocalDate dateOfBirth;
    
    public User(String name, LocalDate dateOfBirth) {
        this.name = name;
        this.dateOfBirth = dateOfBirth;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }
    
    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }
    
    public String getFormattedDateOfBirth() {
        if (dateOfBirth == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");
        return dateOfBirth.format(formatter);
    }
    
    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", dateOfBirth=" + getFormattedDateOfBirth() +
                '}';
    }
} 