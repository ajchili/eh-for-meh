package com.kirinpatel.ehformeh.utils;

public class Theme {

    private String backgroundColor;
    private String accentColor;
    private boolean dark;

    public Theme(String backgroundColor, String accentColor, boolean dark) {
        this.backgroundColor = backgroundColor;
        this.accentColor = accentColor;
        this.dark = dark;
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
