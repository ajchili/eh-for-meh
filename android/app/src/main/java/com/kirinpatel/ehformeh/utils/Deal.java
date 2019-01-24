package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DataSnapshot;

import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;

public class Deal implements Serializable {

    private String id;
    private String features;
    private boolean isPreviousDeal;
    private Item[] items;
    private URL[] photos;
    private boolean soldOut;
    private String specifications;
    private Story story;
    private Theme theme;
    private String title;
    private Topic topic;
    private String url;

    public Deal(String id,
                String features,
                boolean isPreviousDeal,
                Item[] items,
                URL[] photos,
                boolean soldOut,
                String specifications,
                Story story,
                Theme theme,
                String title,
                Topic topic,
                String url) {
        this.id = id;
        this.features = features;
        this.isPreviousDeal = isPreviousDeal;
        this.items = items;
        this.photos = photos;
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
            URL[] photos = parsePhotos(dataSnapshot.child("photos"));
            boolean soldOut = dataSnapshot.hasChild("soldOutAt");
            Story story = Story.parseStory(dataSnapshot.child("story"));
            Theme theme = Theme.parseTheme(dataSnapshot.child("theme"));
            String url = dataSnapshot.child("url").getValue().toString();
            return new Deal(dataSnapshot.child("id").getValue().toString(),
                    dataSnapshot.child("features").getValue().toString(),
                    isPreviousDeal,
                    items,
                    photos,
                    soldOut,
                    dataSnapshot.child("specifications").getValue().toString(),
                    story,
                    theme,
                    dataSnapshot.child("title").getValue().toString(),
                    null,
                    url);
        } else throw new Exception("Provided DataSnapshot is not parsable!");
    }

    private static URL[] parsePhotos(DataSnapshot dataSnapshot) throws MalformedURLException {
        int itemLength = (int) dataSnapshot.getChildrenCount();
        URL[] photos = new URL[itemLength];
        Iterable<DataSnapshot> iterable = dataSnapshot.getChildren();
        for (int i = 0; i < photos.length; i++) {
            DataSnapshot childSnapshot = iterable.iterator().next();
            photos[i] = new URL(childSnapshot.getValue().toString());
        }
        return photos;
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

    public URL[] getPhotos() {
        return photos;
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

    public String getURL() {
        return url;
    }

    public String getMarkdownString() {
        return "Features\n===\n" + features + "\n\n---\n\n" +
                specifications + "\n\n---\n\n" +
                story.getTitle() + "\n===\n" + story.getBody();
    }
}
