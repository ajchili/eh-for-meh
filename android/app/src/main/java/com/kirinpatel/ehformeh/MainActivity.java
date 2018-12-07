package com.kirinpatel.ehformeh;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.graphics.Color;
import android.graphics.Point;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.Item;
import com.kirinpatel.ehformeh.utils.Theme;
import com.pierfrancescosoffritti.slidingdrawer.SlidingDrawer;

import java.net.MalformedURLException;
import java.net.URL;

public class MainActivity extends AppCompatActivity {

    private DatabaseReference databaseReference;
    private ValueEventListener dealEventListener;
    private Deal deal;
    private boolean hasAnimated = false;

    private SlidingDrawer mainLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mainLayout = findViewById(R.id.mainLayout);
        setupSlidingView();

        databaseReference = FirebaseDatabase.getInstance().getReference("currentDeal/deal");
    }

    @Override
    protected void onResume() {
        super.onResume();

        setupCurrentDealListener();
    }

    @Override
    protected void onPause() {
        super.onPause();

        databaseReference.removeEventListener(dealEventListener);
    }

    private void setupSlidingView() {
        mainLayout.setDragView(findViewById(R.id.slidableViewContent));
        calculateScreenHeight();
    }

    private void calculateScreenHeight() {
        ConstraintLayout contentView = findViewById(R.id.contentView);
        ViewGroup.LayoutParams params = contentView.getLayoutParams();

        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        params.height = (int) (size.y * .8);

        contentView.setLayoutParams(new LinearLayout.LayoutParams(params));
    }

    private void animateStart() {
        if (deal != null && !hasAnimated) {
            hasAnimated = true;
            final ConstraintLayout loadingBackground = findViewById(R.id.loadingLayout);
            final ConstraintLayout slidingView = findViewById(R.id.slidableViewContent);
            final TextView loadingTitle = findViewById(R.id.titleTextView);

            ValueAnimator backgroundColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                    getResources().getColor(R.color.white),
                    Color.parseColor(deal.getTheme().getBackgroundColor()));
            backgroundColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    loadingBackground.setBackgroundColor((int) animation.getAnimatedValue());
                }
            });
            backgroundColorAnimation.setDuration(500);

            ValueAnimator titleAlphaAnimation = ValueAnimator.ofFloat(1.0f, 0.0f);
            titleAlphaAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    loadingTitle.setAlpha((float) animation.getAnimatedValue());
                }
            });
            titleAlphaAnimation.setDuration(500);

            backgroundColorAnimation.start();
            titleAlphaAnimation.start();

            titleAlphaAnimation.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationCancel(Animator animation) {
                    super.onAnimationCancel(animation);
                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    super.onAnimationEnd(animation);

                    loadingBackground.setVisibility(View.GONE);
                    mainLayout.setBackgroundColor(Color.parseColor(deal.getTheme().getBackgroundColor()));
                    mainLayout.setVisibility(View.VISIBLE);
                    slidingView.setBackgroundColor(Color.parseColor(deal.getTheme().getAccentColor()));
                }

                @Override
                public void onAnimationRepeat(Animator animation) {
                    super.onAnimationRepeat(animation);
                }

                @Override
                public void onAnimationStart(Animator animation) {
                    super.onAnimationStart(animation);
                }

                @Override
                public void onAnimationPause(Animator animation) {
                    super.onAnimationPause(animation);
                }

                @Override
                public void onAnimationResume(Animator animation) {
                    super.onAnimationResume(animation);
                }
            });
        }
    }

    private void setupCurrentDealListener() {
        dealEventListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                try {
                    Theme dealTheme = new Theme(dataSnapshot.child("theme").child("backgroundColor").getValue().toString(),
                            dataSnapshot.child("theme").child("accentColor").getValue().toString(),
                            dataSnapshot.child("theme").child("foreground").getValue().toString().equals("dark"));

                    int itemLength = (int) dataSnapshot.child("items").getChildrenCount();
                    Item[] items = new Item[itemLength];
                    Iterable<DataSnapshot> iterable = dataSnapshot.child("items").getChildren();
                    for (int i = 0; i < items.length; i++) {
                        DataSnapshot childSnapshot = iterable.iterator().next();
                        items[i] = new Item(childSnapshot.child("id").getValue().toString(),
                                childSnapshot.child("condition").getValue().toString(),
                                Float.parseFloat(childSnapshot.child("price").getValue().toString()));
                    }

                    URL url = null;

                    try {
                        url = new URL(dataSnapshot.child("url").getValue().toString());
                    } catch (MalformedURLException e) {
                        // TODO: handle error
                    }

                    deal = new Deal(dataSnapshot.child("id").getValue().toString(),
                            dataSnapshot.child("features").getValue().toString(),
                            false,
                            items,
                            null,
                            dataSnapshot.child("soldOut").exists(),
                            null,
                            null,
                            dealTheme,
                            dataSnapshot.child("title").getValue().toString(),
                            null,
                            url);

                    animateStart();
                    updateUIWithCurrentDeal();
                } catch (NullPointerException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        databaseReference.addValueEventListener(dealEventListener);
    }

    private void updateUIWithCurrentDeal() {
        if (deal != null) {
            // Title
            TextView dealTitle = findViewById(R.id.dealTitleTextView);
            dealTitle.setText(deal.getTitle());
            dealTitle.setTextColor(Color.parseColor(deal.getTheme().getAccentColor()));

            // Price
            TextView dealPrice = findViewById(R.id.dealPriceTextView);
            Float minPrice = Float.MAX_VALUE;
            Float maxPrice = Float.MIN_VALUE;
            for (Item item : deal.getItems()) {
                Float price = item.getPrice();
                if (price < minPrice) minPrice = price;
                if (price > maxPrice) maxPrice = price;
            }
            String price = "$" + maxPrice;
            if (maxPrice != minPrice) price += " - $" + minPrice;
            dealPrice.setText(price);
        }
    }
}
