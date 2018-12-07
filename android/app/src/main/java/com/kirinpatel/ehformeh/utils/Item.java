package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DataSnapshot;

import java.io.Serializable;

public class Item implements Serializable {

    private String id;
    private String condition;
    private Float price;

    public Item(String id, String condition, Float price) {
        this.id = id;
        this.condition = condition;
        this.price = price;
    }

    private static Item parseItem(DataSnapshot dataSnapshot) throws Exception {
        if (dataSnapshot.hasChild("id") &&
                dataSnapshot.hasChild("condition") &&
                dataSnapshot.hasChild("price")) {
           return new Item(dataSnapshot.child("id").getValue().toString(),
                   dataSnapshot.child("condition").getValue().toString(),
                   Float.parseFloat(dataSnapshot.child("price").getValue().toString()));
        } else throw new Exception("Provided DataSnapshot is not parsable!");
    }

    static Item[] parseItems(DataSnapshot dataSnapshot) throws Exception {
        int itemLength = (int) dataSnapshot.getChildrenCount();
        Item[] items = new Item[itemLength];
        Iterable<DataSnapshot> iterable = dataSnapshot.getChildren();
        for (int i = 0; i < items.length; i++) {
            DataSnapshot childSnapshot = iterable.iterator().next();
            items[i] = parseItem(childSnapshot);
        }
        return items;
    }

    public String getId() {
        return id;
    }

    public String getCondition() {
        return condition;
    }

    public Float getPrice() {
        return price;
    }
}
