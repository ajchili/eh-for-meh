package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DataSnapshot;

import java.io.Serializable;

public class Theme implements Serializable {

    private String backgroundColor;
    private String accentColor;
    private boolean dark;

    public Theme(String backgroundColor, String accentColor, boolean dark) {
        this.backgroundColor = backgroundColor;
        this.accentColor = accentColor;
        this.dark = dark;
    }

    static Theme parseTheme(DataSnapshot dataSnapshot) throws Exception {
        if (dataSnapshot.hasChild("backgroundColor") &&
                dataSnapshot.hasChild("accentColor") &&
                dataSnapshot.hasChild("foreground")) {
            return new Theme(dataSnapshot.child("backgroundColor").getValue().toString(),
                    dataSnapshot.child("accentColor").getValue().toString(),
                    dataSnapshot.child("foreground").getValue().toString().equals("dark"));
        } else throw new Exception("Provided DataSnapshot is not parsable!");
    }

    public String getBackgroundColor() {
        return backgroundColor;
    }

    public String getAccentColor() {
        return accentColor;
    }

    public boolean isDark() {
        return dark;
    }
}
