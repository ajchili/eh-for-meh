package com.kirinpatel.ehformeh.Adapters;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.kirinpatel.ehformeh.R;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.DealPhoto;
import com.kirinpatel.ehformeh.utils.PhotoFetcher;

import java.io.IOException;

public class PhotoAdapter extends RecyclerView.Adapter<PhotoAdapter.PhotoHolder> {

    private Deal deal;

    public PhotoAdapter(Deal deal) {
        this.deal = deal;
    }

    @Override
    public PhotoHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater
                .from(parent.getContext())
                .inflate(R.layout.list_deal_photo, parent,false);
        return new PhotoHolder(view);
    }

    @Override
    public void onBindViewHolder(PhotoHolder holder, int position) {
        DealPhoto photo = deal.getPhotos()[position];
        holder.bind(photo);
    }

    @Override
    public int getItemCount() {
        return deal.getPhotos().length;
    }

    static class PhotoHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private DealPhoto dealPhoto;
        private ProgressBar progressBar;
        private ImageView imageView;

        PhotoHolder(View view) {
            super(view);

            progressBar = view.findViewById(R.id.progressBar);
            imageView = view.findViewById(R.id.imageView);
        }

        @Override
        public void onClick(View view) {

        }

        void bind(DealPhoto dealPhoto) {
            this.dealPhoto = dealPhoto;
            if (this.dealPhoto.getImage() != null) {
                bindImageView();
            } else {
                resetImageView();
                new FetchImagesTask().execute(this.dealPhoto.getUrl());
            }
        }

        void bindImageView() {
            progressBar.setVisibility(View.GONE);
            imageView.setVisibility(View.VISIBLE);
            imageView.setImageBitmap(dealPhoto.getImage());
        }

        void bindImageView(Bitmap bitmap) {
            if (this.dealPhoto.getImage() == null) dealPhoto.setImage(bitmap);
            bindImageView();
        }

        void resetImageView() {
            progressBar.setVisibility(View.VISIBLE);
            imageView.setVisibility(View.GONE);
            imageView.setImageBitmap(null);
        }

        private class FetchImagesTask extends AsyncTask<String, Void, Bitmap> {

            @Override
            protected Bitmap doInBackground(String... urls) {
                if (urls != null && urls[0] != null) {
                    try {
                        byte[] bytes = new PhotoFetcher().getUrlBytes(urls[0]);
                        return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                    } catch (IOException e) {
                        cancel(true);
                        progressBar.setVisibility(View.GONE);
                        return null;
                    }
                }
                return null;
            }

            @Override
            protected void onPostExecute(Bitmap bitmap) {
                super.onPostExecute(bitmap);
                if (bitmap != null) bindImageView(bitmap);
            }
        }
    }
}
