package com.example.mocktest.model;

import java.util.List;
import java.util.ArrayList;

public class Subject {

    public String id;
    public String name;
    private List<String> pdfs;
    private List<String> docs;
    private List<String> videos;
    private List<MCQ> mcqs;
    private List<Chapter> chapters;

    // Default constructor
    public Subject() {
        this.pdfs = new ArrayList<>();
        this.docs = new ArrayList<>();
        this.videos = new ArrayList<>();
        this.mcqs = new ArrayList<>();
        this.chapters = new ArrayList<>();
    }
    
    // Constructor that takes a string - used for deserialization from String values
    public Subject(String id,
                   String name) {
        this.id = id;
        this.name = name;
        this.pdfs = new ArrayList<>();
        this.docs = new ArrayList<>();
        this.videos = new ArrayList<>();
        this.mcqs = new ArrayList<>();
        this.chapters = new ArrayList<>();

    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public List<String> getPdfs() {
        return pdfs;
    }

    public void setPdfs(List<String> pdfs) {
        this.pdfs = pdfs;
    }

    public List<String> getDocs() {
        return docs;
    }

    public void setDocs(List<String> docs) {
        this.docs = docs;
    }

    public List<String> getVideos() {
        return videos;
    }

    public void setVideos(List<String> videos) {
        this.videos = videos;
    }

    public List<MCQ> getMcqs() {
        return mcqs;
    }

    public void setMcqs(List<MCQ> mcqs) {
        this.mcqs = mcqs;
    }

    public List<Chapter> getChapters() {
        return chapters;
    }

    public void setChapters(List<Chapter> chapters) {
        this.chapters = chapters;
    }

    @Override
    public String toString() {
        return name;
    }
}
