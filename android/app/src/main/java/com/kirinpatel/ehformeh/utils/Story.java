package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DataSnapshot;

import java.io.Serializable;

public class Story implements Serializable {

    private String title;
    private String body;

    public Story(String title, String body) {
        this.title = title;
        this.body = body;
    }

    static Story parseStory(DataSnapshot dataSnapshot) throws Exception {
        if (dataSnapshot.hasChild("title") && dataSnapshot.hasChild("body")) {
            return new Story(dataSnapshot.child("title").getValue().toString(),
                    dataSnapshot.child("body").getValue().toString());
        } else throw new Exception("Provided DataSnapshot is not parsable!");
    }
}
