package com.kirinpatel.ehformeh;

import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.kirinpatel.ehformeh.utils.Theme;

public class LoadingActivity extends AppCompatActivity {

    private ConstraintLayout constraintLayout;
    private TextView titleTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_loading);

        constraintLayout = findViewById(R.id.contraintLayout);
        titleTextView = findViewById(R.id.titleTextView);

        loadTheme();
    }

    private void loadTheme() {
        FirebaseDatabase
                .getInstance()
                .getReference("currentDeal/deal/theme")
                .addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.child("backgroundColor").exists()
                        && dataSnapshot.child("accentColor").exists()
                        && dataSnapshot.child("foreground").exists()) {
                    String backgroundColor = dataSnapshot.child("backgroundColor").getValue().toString();
                    String accentColor = dataSnapshot.child("accentColor").getValue().toString();
                    boolean dark = dataSnapshot.child("").getValue().toString().equals("dark");

                    Theme theme = new Theme(backgroundColor, accentColor, dark);
                    animateView(theme);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });
    }

    private void animateView(Theme theme) {
        ValueAnimator backgroundColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                getResources().getColor(R.color.white),
                Color.parseColor(theme.getBackgroundColor()));
        backgroundColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                constraintLayout.setBackgroundColor((int) animation.getAnimatedValue());
            }
        });
        backgroundColorAnimation.setDuration(500);


        ValueAnimator titleAlphaAnimation = ValueAnimator.ofFloat(1.0f, 0.0f);
        titleAlphaAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                titleTextView.setAlpha((float) animation.getAnimatedValue());
            }
        });
        titleAlphaAnimation.setDuration(500);

        backgroundColorAnimation.start();
        titleAlphaAnimation.start();
    }
}
