package com.kirinpatel.ehformeh.utils;

import com.google.firebase.database.DatabaseError;

public interface DealLoaderInterface {
    void dealLoaded(Deal deal);
    void dealUpdated(Deal deal);
    void dealLoadFailed(DatabaseError databaseError);
    void dealNotLoadable(Exception e);
}
