package com.example.mocktest.service;

import com.example.mocktest.model.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
public class DataService {
    private static final Logger logger = LoggerFactory.getLogger(DataService.class);
    private final ObjectMapper objectMapper;
    private List<Group> groups;

    public DataService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.groups = new ArrayList<>();
        loadData();
    }

    private void loadData() {
        try {
            ClassPathResource dataFile = new ClassPathResource("data.json");
            // Parse the root object first, then extract the groups array
            var rootNode = objectMapper.readTree(dataFile.getFile());
            if (rootNode.has("groups")) {
                groups = objectMapper.convertValue(
                    rootNode.get("groups"),
                    objectMapper.getTypeFactory().constructCollectionType(List.class, Group.class)
                );
                logger.info("Successfully loaded {} groups", groups.size());
            } else {
                logger.error("No 'groups' field found in data.json");
            }
        } catch (IOException e) {
            logger.error("Error loading data from data.json", e);
        }
    }

    public List<Group> getGroups() {
        return groups;
    }

    public List<Subgroup> getSubgroups(String groupId) {
        return groups.stream()
                .filter(g -> g.getId().equals(groupId))
                .findFirst()
                .map(Group::getSubgroups)
                .orElse(new ArrayList<>());
    }

    public List<Exam> getExams(String groupId, String subgroupId) {
        return groups.stream()
                .filter(g -> g.getId().equals(groupId))
                .flatMap(g -> g.getSubgroups().stream())
                .filter(s -> s.getId().equals(subgroupId))
                .findFirst()
                .map(Subgroup::getExams)
                .orElse(new ArrayList<>());
    }

    public List<Subject> getSubjects(String groupId, String subgroupId, String examId) {
        return groups.stream()
                .filter(g -> g.getId().equals(groupId))
                .flatMap(g -> g.getSubgroups().stream())
                .filter(s -> s.getId().equals(subgroupId))
                .flatMap(s -> s.getExams().stream())
                .filter(e -> e.getId().equals(examId))
                .findFirst()
                .map(Exam::getSubjects)
                .orElse(new ArrayList<>());
    }

    public List<Chapter> getChapters(String groupId, String subgroupId, String examId, String subjectId) {
        return groups.stream()
                .filter(g -> g.getId().equals(groupId))
                .flatMap(g -> g.getSubgroups().stream())
                .filter(s -> s.getId().equals(subgroupId))
                .flatMap(s -> s.getExams().stream())
                .filter(e -> e.getId().equals(examId))
                .flatMap(e -> e.getSubjects().stream())
                .filter(s-> s.getId().equals(subjectId))
                .findFirst()
                .map(Subject::getChapters)
                .orElse(new ArrayList<>());
    }
}
