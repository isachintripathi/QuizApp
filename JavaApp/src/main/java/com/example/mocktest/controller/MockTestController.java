package com.example.mocktest.controller;

import com.example.mocktest.model.*;
import com.example.mocktest.service.DataService;
import com.example.mocktest.service.MCQService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")  // Allow Flutter to access API
public class MockTestController {

    @Autowired
    private DataService dataService;

    @Autowired
    private MCQService mcqService;

    @GetMapping("/groups")
    public ResponseEntity<List<Group>> getGroups() {
        return ResponseEntity.ok(dataService.getGroups());
    }

    @GetMapping("/subgroups/{groupId}")
    public ResponseEntity<List<Subgroup>> getSubgroups(@PathVariable String groupId) {
        return ResponseEntity.ok(dataService.getSubgroups(groupId));
    }

    @GetMapping("/exams/{groupId}/{subgroupId}")
    public ResponseEntity<List<Exam>> getExams(@PathVariable String groupId, @PathVariable String subgroupId) {
        return ResponseEntity.ok(dataService.getExams(groupId, subgroupId));
    }

    @GetMapping("/subjects/{groupId}/{subgroupId}/{examId}")
    public ResponseEntity<List<Subject>> getSubjects(@PathVariable String groupId, 
                                                   @PathVariable String subgroupId,
                                                   @PathVariable String examId) {
        return ResponseEntity.ok(dataService.getSubjects(groupId, subgroupId, examId));
    }

    @GetMapping("/pdfs/{groupId}/{subgroupId}/{examId}/{subject}")
    public ResponseEntity<List<String>> getPdfs(@PathVariable String groupId,
                                              @PathVariable String subgroupId,
                                              @PathVariable String examId,
                                              @PathVariable String subject) {
        List<Subject> subjects = dataService.getSubjects(groupId, subgroupId, examId);
        return subjects.stream()
                .filter(s -> s.getName().equalsIgnoreCase(subject))
                .findFirst()
                .map(s -> ResponseEntity.ok(s.getPdfs()))
                .orElse(ResponseEntity.ok(new ArrayList<>()));
    }

    @GetMapping("/docs/{groupId}/{subgroupId}/{examId}/{subject}")
    public ResponseEntity<List<String>> getDocs(@PathVariable String groupId,
                                              @PathVariable String subgroupId,
                                              @PathVariable String examId,
                                              @PathVariable String subject) {
        List<Subject> subjects = dataService.getSubjects(groupId, subgroupId, examId);
        return subjects.stream()
                .filter(s -> s.getName().equalsIgnoreCase(subject))
                .findFirst()
                .map(s -> ResponseEntity.ok(s.getDocs()))
                .orElse(ResponseEntity.ok(new ArrayList<>()));
    }

    @GetMapping("/videos/{groupId}/{subgroupId}/{examId}/{subject}")
    public ResponseEntity<List<String>> getVideos(@PathVariable String groupId,
                                                @PathVariable String subgroupId,
                                                @PathVariable String examId,
                                                @PathVariable String subject) {
        List<Subject> subjects = dataService.getSubjects(groupId, subgroupId, examId);
        return subjects.stream()
                .filter(s -> s.getName().equalsIgnoreCase(subject))
                .findFirst()
                .map(s -> ResponseEntity.ok(s.getVideos()))
                .orElse(ResponseEntity.ok(new ArrayList<>()));
    }

    @GetMapping("/mcqs/{subject}")
    public ResponseEntity<List<MCQ>> getMCQs(@PathVariable String subject) {
        return ResponseEntity.ok(mcqService.getMCQsBySubject(subject));
    }

    @GetMapping("/mcqs")
    public ResponseEntity<List<MCQ>> getMCQs(
            @RequestParam(required = false) String topic,
            @RequestParam String subject,
            @RequestParam(defaultValue = "10") int count,
            @RequestParam(required = false) String userId) {
        List<MCQ> result;
        if (topic != null && !topic.isEmpty()) {
            result = mcqService.getMCQsForTopicAndSubject(topic, subject, count, userId);
        } else {
            result = mcqService.getMCQsBySubject(subject);
            // If there are more MCQs than the requested count, limit them
            if (result.size() > count) {
                result = result.subList(0, count);
            }
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/mcq-stats")
    public Map<String, Object> getMcqStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalMCQs", mcqService.getTotalMCQCount());
        return stats;
    }

    @PostMapping("/reset-mcq-tracking")
    public Map<String, String> resetMcqTracking(@RequestParam(required = false) String userId) {
        mcqService.resetRecentlyServedMCQs();
        Map<String, String> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "MCQ tracking reset successfully");
        return response;
    }
}
