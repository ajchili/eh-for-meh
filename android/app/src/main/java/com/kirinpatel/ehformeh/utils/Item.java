package com.kirinpatel.ehformeh.utils;

import java.io.Serializable;

public class Item implements Serializable {

    private String id;
    private String condition;
    private Float price;

    public Item (String id, String condition, Float price) {
        this.id = id;
        this.condition = condition;
        this.price = price;
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
