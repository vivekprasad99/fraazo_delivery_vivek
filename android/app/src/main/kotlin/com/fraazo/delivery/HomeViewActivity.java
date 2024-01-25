package com.fraazo.delivery;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.MenuItem;

import androidx.appcompat.app.AppCompatActivity;

import com.loctoc.knownuggetssdk.Helper;
import com.loctoc.knownuggetssdk.activities.ShareActivity;
import com.loctoc.knownuggetssdk.modelClasses.feed.Feed;
import com.loctoc.knownuggetssdk.views.feed.RecyclerViewFeed;

public class HomeViewActivity extends AppCompatActivity implements RecyclerViewFeed.OnFeedInteractionListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home_view);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowTitleEnabled(true);
        getSupportActionBar().setElevation(0);
        getSupportActionBar().setTitle("All Notifications");
        ColorDrawable colorDrawable
                = new ColorDrawable(Color.parseColor("#43C6AC"));

        // Set BackgroundDrawable
        getSupportActionBar().setBackgroundDrawable(colorDrawable);
    }

    @Override
    public void nuggetLoaded() {

    }

    @Override
    public void onShareClicked(Feed feed, int i, boolean b) {
        Intent intent = new Intent(this, ShareActivity.class);
        intent.putExtra("nuggetId", feed.getNugget().getKey());
        intent.putExtra("authorId", Helper.getUser().getUid());
        if (b) {
            intent.putExtra("showOnlyGroups", false);
            intent.putExtra("isFromIncidentShare", true);
        }
        if (feed.getClassificationType().equals("general")) {
            intent.putExtra("classificationType", "general");
        } else if (feed.getClassificationType().equals("tasklist")) {
            intent.putExtra("classificationType", "tasklist");
        } else if (feed.getClassificationType().equals("training")) {
            intent.putExtra("classificationType", "training");
        }
        startActivity(intent);
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
        }
        return true;
    }
}
