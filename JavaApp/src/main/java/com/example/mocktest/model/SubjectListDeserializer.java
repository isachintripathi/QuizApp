package com.example.mocktest.model;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonNode;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SubjectListDeserializer extends JsonDeserializer<List<Subject>> {
    @Override
    public List<Subject> deserialize(JsonParser p, DeserializationContext ctxt) 
            throws IOException, JsonProcessingException {
        JsonNode node = p.getCodec().readTree(p);
        List<Subject> subjects = new ArrayList<>();
        
        if (node.isArray()) {
            for (JsonNode subjectNode : node) {
                Subject subject = new Subject();
                if (subjectNode.isObject()) {
                    subject.setName(subjectNode.get("name").asText());
//                    subject.setId(subjectNode.get("id").asText());
                    // Set other fields if they exist in the JSON
                    if (subjectNode.has("pdfs")) {
                        List<String> pdfs = new ArrayList<>();
                        subjectNode.get("pdfs").forEach(pdf -> pdfs.add(pdf.asText()));
                        subject.setPdfs(pdfs);
                    }
                    if (subjectNode.has("docs")) {
                        List<String> docs = new ArrayList<>();
                        subjectNode.get("docs").forEach(doc -> docs.add(doc.asText()));
                        subject.setDocs(docs);
                    }
                    if (subjectNode.has("videos")) {
                        List<String> videos = new ArrayList<>();
                        subjectNode.get("videos").forEach(video -> videos.add(video.asText()));
                        subject.setVideos(videos);
                    }
                    if (subjectNode.has("mcqs")) {
                        List<MCQ> mcqs = new ArrayList<>();
                        subjectNode.get("mcqs").forEach(mcqNode -> {
                            MCQ mcq = new MCQ();
                            mcq.setId(mcqNode.get("id").asText());
                            mcq.setQuestion(mcqNode.get("question").asText());
                            mcq.setOptions(new ArrayList<>());
                            mcqNode.get("options").forEach(option -> mcq.getOptions().add(option.asText()));
                            mcq.setCorrectAnswerIndex(mcqNode.get("correctAnswerIndex").asInt());
                            if (mcqNode.has("explanation")) {
                                mcq.setExplanation(mcqNode.get("explanation").asText());
                            }
                            mcqs.add(mcq);
                        });
                        subject.setMcqs(mcqs);
                    }
                } else {
                    subject.setName(subjectNode.asText());
                }
                subjects.add(subject);
            }
        }
        
        return subjects;
    }
}
