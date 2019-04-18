package com.kirinpatel.ehformeh.utils;

import android.graphics.Bitmap;

import java.io.Serializable;

public class DealPhoto implements Serializable {

    private String url;
    private Bitmap image;

    public DealPhoto(String url) {
        this.url = url;
    }

    public DealPhoto(String url, Bitmap image) {
        this.url = url;
        this.image = image;
    }

    public void setImage(Bitmap image) {
        this.image = image;
    }

    public String getUrl() {
        return url;
    }

    public Bitmap getImage() {
        return image;
    }
}
