package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DataSnapshot;

import java.io.Serializable;
import java.net.URL;

public class Deal implements Serializable {

    private String id;
    private String features;
    private boolean isPreviousDeal;
    private Item[] items;
    private URL[] urls;
    private boolean soldOut;
    private String specifications;
    private Story story;
    private Theme theme;
    private String title;
    private Topic topic;
    private URL url;

    public Deal(String id,
                String features,
                boolean isPreviousDeal,
                Item[] items,
                URL[] urls,
                boolean soldOut,
                String specifications,
                Story story,
                Theme theme,
                String title,
                Topic topic,
                URL url) {
        this.id = id;
        this.features = features;
        this.isPreviousDeal = isPreviousDeal;
        this.items = items;
        this.urls = urls;
        this.soldOut = soldOut;
        this.specifications = specifications;
        this.story = story;
        this.theme = theme;
        this.title = title;
        this.topic = topic;
        this.url = url;
    }

    static Deal parseDeal(DataSnapshot dataSnapshot) throws Exception {
        if (dataSnapshot.hasChild("features") &&
                dataSnapshot.hasChild("id") &&
                dataSnapshot.hasChild("items") &&
                dataSnapshot.hasChild("photos") &&
                dataSnapshot.hasChild("specifications") &&
                dataSnapshot.hasChild("story") &&
                dataSnapshot.hasChild("theme") &&
                dataSnapshot.hasChild("title") &&
                dataSnapshot.hasChild("topic") &&
                dataSnapshot.hasChild("url")) {
            boolean isPreviousDeal = dataSnapshot.getRef().getParent().getKey().equals("currentDeal");
            Item[] items = Item.parseItems(dataSnapshot.child("items"));
            boolean soldOut = dataSnapshot.hasChild("soldOutAt");
            Story story = Story.parseStory(dataSnapshot.child("story"));
            Theme theme = Theme.parseTheme(dataSnapshot.child("theme"));
            return new Deal(dataSnapshot.child("id").getValue().toString(),
                    dataSnapshot.child("features").getValue().toString(),
                    isPreviousDeal,
                    items,
                    null,
                    soldOut,
                    dataSnapshot.child("specifications").getValue().toString(),
                    story,
                    theme,
                    dataSnapshot.child("title").getValue().toString(),
                    null,
                    null);
        } else throw new Exception("Provided DataSnapshot is not parsable!");
    }

    public String getId() {
        return id;
    }

    public String getFeatures() {
        return features;
    }

    public boolean isPreviousDeal() {
        return isPreviousDeal;
    }

    public Item[] getItems() {
        return items;
    }

    public URL[] getUrls() {
        return urls;
    }

    public boolean isSoldOut() {
        return soldOut;
    }

    public String getSpecifications() {
        return specifications;
    }

    public Story getStory() {
        return story;
    }

    public Theme getTheme() {
        return theme;
    }

    public String getTitle() {
        return title;
    }

    public Topic getTopic() {
        return topic;
    }

    public URL getURL() {
        return url;
    }
}
