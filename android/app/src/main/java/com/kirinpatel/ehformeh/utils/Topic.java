package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DataSnapshot;

import java.io.Serializable;
import java.net.URL;

public class Topic implements Serializable {

    private String id;
    private String url;

    public Topic (String id, String url) {
        this.id = id;
        this.url = url;
    }

    static Topic parse(DataSnapshot dataSnapshot) throws Exception {
        if (dataSnapshot.hasChild("id") && dataSnapshot.hasChild("url")) {
            return new Topic(dataSnapshot.child("id").getValue().toString(),
                    dataSnapshot.child("url").getValue().toString());
        } else throw new Exception("Provided DataSnapshot is not parsable!");
    }

    public String getId() {
        return id;
    }

    public String getUrl() {
        return url;
    }
}
