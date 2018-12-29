package com.kirinpatel.ehformeh.utils;

import android.support.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class DealLoader {

    private DealLoaderInterface listener;
    private boolean isInitialLoad = true;

    public DealLoader(DealLoaderInterface listener) {
        this.listener = listener;
    }

    public void loadCurrentDeal() {
        FirebaseDatabase
                .getInstance()
                .getReference("currentDeal/deal")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                        try {
                            Deal deal = Deal.parseDeal(dataSnapshot);
                            listener.dealLoaded(deal);
                        } catch (Exception e) {
                            listener.dealNotLoadable(e);
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError databaseError) {
                        listener.dealLoadFailed(databaseError);
                    }
                });
    }

    public void watchCurrentDeal() {
        isInitialLoad = true;
        FirebaseDatabase
                .getInstance()
                .getReference("currentDeal/deal")
                .addValueEventListener(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                        try {
                            Deal deal = Deal.parseDeal(dataSnapshot);
                            if (isInitialLoad) {
                                listener.dealLoaded(deal);
                            } else {
                                listener.dealUpdated(deal);
                            }
                        } catch (Exception e) {
                            listener.dealNotLoadable(e);
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError databaseError) {
                        listener.dealLoadFailed(databaseError);
                    }
                });
    }
}
